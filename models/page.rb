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

  has n, :_outbound_links, 'Page::Link', :child_key => [:source_host, :source_path]
  has n, :linked_pages, self, :through => :_outbound_links, :via => :target

  has n, :_inbound_links, 'Page::Link', :child_key => [:target_host, :target_path]
  has n, :linking_pages, self, :through => :_inbound_links, :via => :source

  def links_to! page
    self.class::Link.first_or_create(:source => self, :target => page).save
    self
  end

  def links_to? page
    self.linked_pages.include? page
  end

  def is_linked_from! page
    self.class::Link.first_or_create(:source => page, :target => self).save
    self
  end

  def is_linked_from? page
    self.linking_pages.include? page
  end

  def is_not_linked_from! page
    link = Link.first(:source => page, :target => self) and link.destroy
    self
  end

  def is_not_linked_from? page
    !self.is_linked_from? page
  end

  def does_not_link_to! page
    link = Link.first(:source => self, :target => page) and link.destroy
    self
  end

  def does_not_link_to? page
    !self.links_to? page
  end

  def outbound_links= pages
    self._outbound_links.destroy
    return unless pages.respond_to? :each
    pages.each do |page|
      self.links_to! page if page.is_a? Page
    end
  end

  def inbound_links= pages
    self._inbound_links.destroy
    return unless pages.respond_to? :each
    pages.each do |page|
      self.is_linked_from! page if page.is_a? Page
    end
  end

end
