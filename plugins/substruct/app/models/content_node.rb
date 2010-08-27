# ContentNode is the base class for all of our content.
#
class ContentNode < ActiveRecord::Base
  belongs_to :content_node_type
  belongs_to :user
  has_and_belongs_to_many :sections
  
  TYPES = ['Blog', 'Page', 'Snippet']
  
  alias_attribute :url, :name
  
  #############################################################################
  # VALIDATION
  #############################################################################

  before_validation :clean_url
  before_validation :check_type
  
  validates_inclusion_of :type, :in => TYPES
  validates_presence_of :name, :title, :content
  validates_uniqueness_of :name, 
    :message => 'This URL has already been taken. Create a unique URL please.'

  
  # Simply sets display date if we don't do it.
  def before_save
    self.display_on = Date.today unless self.display_on
  end

  #############################################################################
  # INSTANCE METHODS
  #############################################################################

	# Defined to save sections from edit view
	def sections=(list)
		sections.clear
		for id in list
			sections << Section.find(id) if !id.empty?
		end
	end

  # Lets us know if this is a blog post or not
  def is_blog_post?
    self.type == 'Blog'
  end
  
  private
    # Inserts URL from content name, and makes it save for URL usage.
    def clean_url
      self.url = self.title if self.url.blank?
      
      self.url.downcase!
      self.url = self.url.gsub(/[^[:alnum:]]/,'-').gsub(/-{2,}/,'-')
      self.url = self.url.gsub(/^[-]/,'').gsub(/[-]$/,'')
      self.url.strip!

      return true
  	end
  	
  	# Ensures we have a proper type before saving.
  	def check_type
  	  self.type = TYPES[0] if !TYPES.include?(self.type)
	  end
end