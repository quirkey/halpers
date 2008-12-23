module QuirkeyTestHelper

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

  def uploaded_file(path, content_type="application/octet-stream", filename=nil)
    filename ||= File.basename(path)
    t = Tempfile.new(filename)
    FileUtils.copy_file(path, t.path)
    (class << t; self; end;).class_eval do
      alias local_path path
      define_method(:original_filename) { filename }
      define_method(:content_type) { content_type }
    end
    return t
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

  def assert_redirected_to_login
    assert_redirected_to "/login"
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

  def assert_relative_times(expected, test)
    assert expected, "Expected time is nil"
    assert test, "Test time is nil"
    assert((expected - test).to_i < 10 && (expected - test).to_i > - 10, "Times #{expected} : #{test} are not relative")
  end

  def logout
    @request.session[:user] = nil
  end

  def assert_validates_presence_of(klass, meths)
    k = klass.create
    assert !k.id
    assert_errors_on k, meths
  end

  def assert_validates_uniqueness_of(test_instance,meths)
    k = test_instance.class.create(test_instance.attributes.reject {|i,v| i == 'id' })
    assert !k.id
    assert_errors_on k, meths
  end

  def assert_errors_on(ob, meths)
    meths.each do |meth|
      assert ob.errors.on(meth), "#{ob.class}.#{meth} should have errors"
    end
  end

  def assert_all(collection)
    collection.each do |one|
      assert yield(one), "#{one.inspect} is not true"
    end
  end
  
  def assert_assigns(expected, assigned, message = nil)
    message ||= "should assign #{expected} to @#{assigned}"
    assert_equal(expected, assigns(assigned), message)
  end

  def assert_any(collection, &block)
    has = collection.any? do |one|
      yield(one)
    end
    assert has
  end

  def assert_ordered(array_of_ordered_items, message = nil, &block)
    raise "Parameter must be an Array" unless array_of_ordered_items.is_a?(Array)
    message ||= "Items were not in the correct order"
    i = 0
    # puts array_of_ordered_items.length
    while i < (array_of_ordered_items.length - 1)
      # puts "j"
      a, b = array_of_ordered_items[i], array_of_ordered_items[i+1]
      comparison = yield(a,b)
      # raise "#{comparison}"
      assert(comparison, message + " - #{a}, #{b}")
      i += 1
    end
  end
  
  def assert_set_of(klass, set)
    assert set.respond_to?(:each), "#{set.inspect} is not a set (does not include Enumerable)"
    assert_all(set) {|a| a.is_a?(klass) }
  end
  
end