require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

describe "Page Model" do
  it 'can construct a new instance' do
    @page = Page.new
    refute_nil @page
  end

  it 'can have incoming and outgoing links' do
    p1 = Page.create
    p1.host = 'p'
    p1.path = '1'
    p1.save

    p2 = Page.create
    p2.host = 'p'
    p2.path = '2'
    p2.save

    p1.links_to p2

    p1.outgoing_links.must_include p2
    p2.incoming_links.must_include p1

  end

end
