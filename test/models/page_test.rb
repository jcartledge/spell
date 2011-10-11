require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

describe "Page Model" do
  it 'can construct a new instance' do
    @page = Page.new
    refute_nil @page
  end
end
