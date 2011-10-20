class Page

  class Link

    include DataMapper::Resource

    storage_names[:default] = 'page_links'

    belongs_to :source, 'Page', :key => true
    belongs_to :target, 'Page', :key => true

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

  has n, :outgoing_links, 'Page::Link', :child_key => [:target_host, :target_path]
  has n, :outgoing_pages, self, :through => :outgoing_links, :via => :target

  has n, :incoming_links, 'Page::Link', :child_key => [:source_host, :source_path]
  has n, :incoming_pages, self, :through => :incoming_links, :via => :source

end
