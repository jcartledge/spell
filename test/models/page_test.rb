require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

describe "Page Model" do

  before do
    Page.destroy!
    Page::Link.destroy!

    @pages = []
    (0..9).each do |path|
      page = Page.create(:host => 'p', :path => path)
      page.save
      @pages.push page
    end
  end

  it 'can construct a new instance' do
    page = Page.new
    refute_nil page
  end

  it 'can have incoming links' do
    @pages[0].is_linked_from! @pages[1]

    true.must_equal @pages[0].is_linked_from? @pages[1]
    true.must_equal @pages[1].links_to? @pages[0]
    true.wont_equal @pages[1].is_linked_from? @pages[0]
    true.wont_equal @pages[0].links_to? @pages[1]
  end

  it 'can have outgoing links' do
    @pages[0].links_to! @pages[1]

    true.must_equal @pages[0].links_to? @pages[1]
    true.must_equal @pages[1].is_linked_from? @pages[0]
    true.wont_equal @pages[1].links_to? @pages[0]
    true.wont_equal @pages[0].is_linked_from?@pages[1]
  end

  it 'allows incoming links to be deleted' do
    @pages[0].is_linked_from! @pages[1]
    @pages[0].is_not_linked_from! @pages[1]

    true.wont_equal @pages[0].is_linked_from? @pages[1]
    true.wont_equal @pages[1].links_to? @pages[0]
  end

  it 'allows outgoing links to be deleted' do
    @pages[0].links_to! @pages[1]
    @pages[0].does_not_link_to! @pages[1]

    true.must_equal @pages[0].does_not_link_to? @pages[1]
    true.must_equal @pages[1].is_not_linked_from? @pages[0]
  end

  it 'allows linking to be chained' do
    @pages[0].must_equal @pages[0].links_to! @pages[1]
    @pages[1].must_equal @pages[1].is_linked_from! @pages[0]
    @pages[0].must_equal @pages[0].does_not_link_to! @pages[1]
    @pages[1].must_equal @pages[1].is_not_linked_from! @pages[0]
  end

  it 'allows all outbound links to be destroyed' do
    @pages[0].links_to! @pages[1]
    @pages[0].outbound_links = nil

    true.must_equal @pages[0].does_not_link_to? @pages[1]
    true.must_equal @pages[1].is_not_linked_from? @pages[0]
  end

  it 'allows all incoming links to be destroyed' do
    @pages[0].links_to! @pages[1]
    @pages[1].inbound_links = nil

    true.must_equal @pages[0].does_not_link_to? @pages[1]
    true.must_equal @pages[1].is_not_linked_from? @pages[0]
  end

  it 'allows all outbound links to be replaced' do
    @pages[0].links_to! @pages[1]
    @pages[0].outbound_links = [@pages[2], @pages[3]]

    true.must_equal @pages[0].does_not_link_to? @pages[1]
    true.must_equal @pages[0].links_to? @pages[2]
    true.must_equal @pages[0].links_to? @pages[3]
    true.must_equal @pages[3].is_linked_from? @pages[0]
  end

  it 'allows all inbound links to be replaced' do
    @pages[0].is_linked_from! @pages[1]
    @pages[0].inbound_links = [@pages[2], @pages[3]]

    true.must_equal @pages[0].is_not_linked_from? @pages[1]
    true.must_equal @pages[0].is_linked_from? @pages[2]
    true.must_equal @pages[0].is_linked_from? @pages[3]
    true.must_equal @pages[3].links_to? @pages[0]
  end

end
