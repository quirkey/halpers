$:.unshift(File.dirname(__FILE__))
require 'test_helpers/upload'
require 'test_helpers/collections'
require 'test_helpers/login'

module QuirkeyTestHelper
  include UploadTestHelper
  include CollectionsTestHelper
  include LoginTestHelper
  
  def assert_toggled(object, method = nil, toggled = true)
    initial_value = object.send(method)
    yield
    object.reload unless object.is_a?(Class)
    new_value = toggled ? !initial_value : initial_value
    assert_equal new_value, object.send(method), "#{object}##{method}"
  end

  def assert_same_as_before(object, method, &block)
    assert_toggled object, method, false, &block
  end

  def assert_flash(key, content)
    assert flash.include?(key),
    "#{key.inspect} missing from flash, has #{flash.keys.inspect}"

    case content
    when Regexp then
      assert_match content, flash[key],
      "Content of flash[#{key.inspect}] did not match"
    else
      assert_equal content, flash[key],
      "Incorrect content in flash[#{key.inspect}]"
    end
  end

  def assert_content_type(content_type)
    assert_equal content_type, @response.content_type 
  end

  def assert_header(header, type, message = nil)
    assert_equal type, @response.headers[header], message
  end

  def assert_shows_errors(eid = 'errorExplanation')
    assert_select "div##{eid}", 1, "Should display div with id=#{eid}"
  end

  def assert_dom_id(record, tag = 'div', count = 1)
    dom_id =  dom_id(record)
    assert_select "#{tag}##{dom_id}", count, "Could not find #{tag} with id=#{dom_id}"
  end

  def dom_id(record)
    ActionController::RecordIdentifier.dom_id(record)
  end

  def items_to_post_hash(items)
    post_hash = {}
    items.collect {|i| post_hash[i.id.to_s] = i.attributes }; post_hash
  end

  def assert_relative_times(expected, test, range = 100)
    assert expected, "Expected time is nil"
    assert test, "Test time is nil"
    assert((expected - test).to_i < range && (expected - test).to_i > (-range), "Times #{expected} : #{test} are not relative")
  end

  def assert_errors_on(ob, *meths)
    [meths].flatten.each do |meth|
      assert ob.errors.on(meth), "#{ob.class}.#{meth} should have errors"
    end
  end
  
end