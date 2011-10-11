require 'net/http'
require 'nokogiri'
require 'resque'
require 'resque-loner'

require File.dirname(__FILE__) + '/../models/page.rb'

# also lots of other stuff like head, check if-modified-since etc
# ROBOTS.TXT FFS
# really, should have headchecker, bodychecker
# then plugins like linkchecker, spellchecker etc
# also error handling
# and redirects
class Crawler

  include Resque::Plugins::UniqueJob

  @queue = 'crawler'

  def self.perform(uri)

    begin
      uri = URI.parse(uri)
    rescue
      p 'thats fuct up'
      return
    end

    # check if we've already crawled this
    # @TODO check when it was crawled and refresh
    if Page.get(uri.host, uri.path)
      p "** Already know about #{uri.host}#{uri.path}"
      return
    end

    # do head request - save with status
    req = Net::HTTP.new(uri.host)
    res = req.request_head(uri.path)
    is_redirect = res.class < Net::HTTPRedirection
    page = {
      :host => uri.host,
      :path => uri.path,
      :status => res.code,
      :message => res.message
    }
    page[:location] = res['location'] if is_redirect
    Page.new(page).save

    # push the redirect on the queue and bail
    if is_redirect
      redirect = URI.parse(res['location'])
      if redirect.host == uri.host
        p "** Queueing redirection to #{redirect.host}#{redirect.path}"
        Resque.enqueue(Crawler, redirect.to_s)
      end
      return
    end

    # if it was successful, and it's HTML we can crawl it
    if res.class < Net::HTTPSuccess && res['Content-type'].match(/html/)

      # get the body, parse out links and queue them for crawling
      body = Nokogiri::HTML(req.request_get(uri.path).body)
      body.css('a[@href]').each do |a|
        link_uri = URI.parse(a[:href])

        # only looking at links on this host - need to look at external links
        if link_uri.host == nil || link_uri.host == uri.host
          next unless link_path = link_uri.path
          link_uri.host = uri.host
          link_uri.fragment = nil
          link_uri.path = self.relative_link(link_path, uri.path)
          Resque.enqueue(Crawler, link_uri.to_s) unless link_path == nil
        end
      end
    end

  end

  def self.relative_link(link_path, current_path = '/')

    # if link_path stats with slash it's already relative to root
    # so ignore current_path
    return link_path if link_path.match(/^\//)

    # if current_path ends with / (and link_path doesn't start with /)
    # just concatenate them
    return current_path + link_path if current_path.match(/\/$/)

    # if we're still here, need to chop current_path back to last /
    # and concat
    current_path = current_path.match(/.*\//).to_s || '/'
    return current_path + link_path
  end

end
