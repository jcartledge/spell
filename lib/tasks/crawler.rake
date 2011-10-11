require File.dirname(__FILE__) + "/../../crawler"

namespace :crawler do
  task :seed => :environment do
    Resque.enqueue(Crawler, 'http://dev.vu.edu.au/')
  end
end
