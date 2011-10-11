class Page

  class Link

    include DataMapper::Resource

    storage_names[:default] = 'links'
    belongs_to :outgoing, 'Page', :key => true
    belongs_to :incoming, 'Page', :key => true

    property :id, Serial

  end

  include DataMapper::Resource

  property :host,       String, :key => true
  property :path,       String, :key => true
  property :status,     Integer
  property :message,    String
  property :location,   String
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :outgoing_links, 'Page::Link',
    :child_key => [:outgoing_host, :outgoing_path]

  has n, :incoming_links, 'Page::Link',
    :child_key => [:incoming_host, :incoming_path]

  has n, :outgoing_pages, self, :through => :outgoing_links, :via => :outgoing
  has n, :incoming_pages, self, :through => :incoming_links, :via => :incoming

  def add_link(*pages)
    outgoing_pages.concat(pages)
    pages.each { |page| page.add_incoming(self) }
    save
    self
  end

  def add_incoming(*pages)
    incoming_pages.concat(pages)
    save
    self
  end

end
