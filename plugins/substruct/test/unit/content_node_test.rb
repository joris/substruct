require File.dirname(__FILE__) + '/../test_helper'

class ContentNodeTest < ActiveSupport::TestCase
  fixtures :content_nodes, :sections


  # Test if a valid content node can be created with success.
  def test_should_create_content_node
    a_content_node = ContentNode.new
    
    a_content_node.name = "prophecies"
    a_content_node.created_on = "2008-02-29 18:15:28 -03:00"
    a_content_node.title = "Prophecies for 2008"
    a_content_node.type = "Blog"
    a_content_node.display_on = 1.minute.ago.to_s(:db)
    a_content_node.content = "According to the Church of Who Knows Where:
    1. The Lord say there would be some scientific breakthrough this year.
    2. There would be some major medical breakthrough this year.
    3. We must pray against destructive hurricane.
    4. To be fore warned is to be fore armed, the flood in this year will be more than last year.
    "

    assert a_content_node.save
  end


  # VALIDATIONS ---------------------------------------------------------------

  # Test if a content node will have its name cleaned before being validated.
  def test_should_have_a_clean_name_before_validated
    a_content_node = ContentNode.new
    
    a_content_node.name = "Prophecies for!'2008'?"
    a_content_node.valid?
    assert_equal a_content_node.name, "prophecies-for-2008"
  end


  # Test if an invalid content node really will NOT be created.
  def test_should_not_create_invalid_content_node
    a_content_node = ContentNode.new
    assert !a_content_node.valid?
    assert a_content_node.errors.invalid?(:name)
    assert a_content_node.errors.invalid?(:title)
    assert a_content_node.errors.invalid?(:content)
    # A content node must have a name, a title and a content.
    assert_equal "can't be blank", a_content_node.errors.on(:name)
    assert_equal "can't be blank", a_content_node.errors.on(:title)
    assert_equal "can't be blank", a_content_node.errors.on(:content)
  end
  
  def test_node_validates_unique_url
    dupe_node = content_nodes(:silent_birth)
    assert dupe_node.update_attribute(:url, 'unique-url')
    
    node = ContentNode.new
    node.attributes = content_nodes(:silent_birth).attributes

    assert !node.save
    assert_equal(
      "This URL has already been taken. Create a unique URL please.", 
      node.errors.on(:name)
    )
  end
  
  def test_saves_with_valid_types
    n = ContentNode.new(
      :title => 'My title',
      :content => 'Good content'
    )
    ContentNode::TYPES.each do |type|
      n.type = type
      assert n.save
      assert_equal type, n.type
    end
  end
  
  def test_doesnt_save_with_invalid_types
    n = ContentNode.new(
      :title => 'My title',
      :content => 'Good content'
    )
    invalid_types = ['some', 'invalid', 'types']
    invalid_types.each do |type|
      n.type = type
      assert n.save
      assert_equal 'Blog', n.type
    end
  end

  # INSTANCE METHODS ----------------------------------------------------------

  # Test if a content node can be found with success.
  def test_should_find_content_node
    a_content_node_id = content_nodes(:silent_birth).id
    assert_nothing_raised {
      ContentNode.find(a_content_node_id)
    }
  end


  # Test if a content node can be updated with success.
  def test_should_update_content_node
    a_content_node = content_nodes(:silent_birth)
    assert a_content_node.update_attributes(:name => 'silent')
  end


  # Test if a content node can be destroyed with success.
  def test_should_destroy_content_node
    a_content_node = content_nodes(:silent_birth)
    a_content_node.destroy
    assert_raise(ActiveRecord::RecordNotFound) {
      ContentNode.find(a_content_node.id)
    }
  end


  
  def test_node_saves_generates_url
    node = ContentNode.new(
      :title => "Some wonderful piece of content",
      :content => "Blah blah blah"
    )
    assert node.save
    assert_equal(
      'some-wonderful-piece-of-content',
      node.name
    )
  end
  
  def test_node_generates_display_date_when_null
    node = ContentNode.new(
      :title => "Some wonderful piece of content",
      :content => "Blah blah blah"
    )
    assert_nil node.display_on
    
    assert node.save
    assert_equal(
      Date.today,
      node.display_on
    )
  end
  
  def test_node_doesnt_overwrite_date
    node = content_nodes(:silent_birth)
    node_publish_date = node.display_on
    assert_not_equal Date.today, node_publish_date
    assert node.save
    assert_equal node_publish_date, node.display_on
  end

  # TODO: Get rid of this method if it will not be used.
  # Test if a content node is a blog post.
  def test_should_discover_if_content_node_is_a_blog_post
    assert content_nodes(:silent_birth).is_blog_post?
  end

  # Test if we can associate a section.
  def test_should_associate_sections
    a_content_node = content_nodes(:tinkerbel_pregnant)
    
    assert_equal a_content_node.sections.count, 0
    
    # Sections must be passed as an array of strings with numeric values.
    a_content_node.sections =  ["", "#{sections(:junk_food_news).id}", "#{sections(:celebrity_pregnancies).id}"]
    a_content_node.save
    a_content_node.reload
    assert_equal a_content_node.sections.count, 2
  end

  # TODO: Get rid of this method if it will not be used.
  # Test if the name will be returned when we ask for its url.
  def test_should_return_name_on_url
    a_content_node = content_nodes(:tinkerbel_pregnant)
    assert_equal a_content_node.url, a_content_node.name
  end

end
