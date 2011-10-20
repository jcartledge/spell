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

  has n, :_outgoing_links, 'Page::Link', :child_key => [:source_host, :source_path]
  has n, :outgoing_links, self, :through => :_outgoing_links, :via => :target

  has n, :_incoming_links, 'Page::Link', :child_key => [:target_host, :target_path]
  has n, :incoming_links, self, :through => :_incoming_links, :via => :source

  def links_to page
    self.class::Link.first_or_create(:source => self, :target => page).save
  end

  def is_linked_from page
    self.class::Link.first_or_create(:source => page, :target => self).save
  end

end
