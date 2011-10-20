require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

describe "Page Model" do

  before do
    Page.destroy!
    Page::Link.destroy!

    @p1 = Page.create(:host => 'p', :path => '1')
    @p1.save

    @p2 = Page.create(:host => 'p', :path => '2')
    @p2.save
  end

  it 'can construct a new instance' do
    @page = Page.new
    refute_nil @page
  end

  it 'can have incoming links' do
    @p1.is_linked_from @p2

    @p1.incoming_links.must_include @p2
    @p1.outgoing_links.wont_include @p2

    @p2.outgoing_links.must_include @p1
    @p2.incoming_links.wont_include @p1
  end

  it 'can have outgoing links' do
    @p1.links_to @p2

    @p1.outgoing_links.must_include @p2
    @p1.incoming_links.wont_include @p2

    @p2.incoming_links.must_include @p1
    @p2.outgoing_links.wont_include @p1
  end

end
