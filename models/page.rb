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

  # add an outbound link from self to page
  # and an inbound link to page from self
  # return self for chaining
  def links_to! page
    self.class::Link.first_or_create(:source => self, :target => page).save
    self
  end

  # bool does self link to page?
  def links_to? page
    self.linked_pages.include? page
  end

  # add an inbound link to self from page
  # and an outbound link from page to self
  # return self for chaining
  def is_linked_from! page
    self.class::Link.first_or_create(:source => page, :target => self).save
    self
  end

  # bool is page linked from self?
  def is_linked_from? page
    self.linking_pages.include? page
  end

  # remove inbound link to self from page
  # and outbound link from page to self
  # return self for chaining
  def is_not_linked_from! page
    link = Link.first(:source => page, :target => self) and link.destroy
    self
  end

  # bool is page not linked from self?
  def is_not_linked_from? page
    !self.is_linked_from? page
  end

  # remove outbound link from self to page
  # and inbound link to page from self
  # return self for chaining
  def does_not_link_to! page
    link = Link.first(:source => self, :target => page) and link.destroy
    self
  end

  # bool does self not link to page?
  def does_not_link_to? page
    !self.links_to? page
  end

  # set outbound links
  # pages = nil or [Page]
  def outbound_links= pages
    self._outbound_links.destroy
    pages.respond_to? :each and pages.each do |page|
      self.links_to! page if page.is_a? Page
    end
  end

  # set inbound links
  # pages = nil or [Page]
  def inbound_links= pages
    self._inbound_links.destroy
    pages.respond_to? :each and pages.each do |page|
      self.is_linked_from! page if page.is_a? Page
    end
  end

end
