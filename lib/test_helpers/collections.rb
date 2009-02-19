module CollectionsTestHelper
  
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
  
  def assert_paginated(collection)
    collection = assigns(collection) if collection.is_a?(Symbol)
    assert collection, "Should not be nil"
    assert collection.respond_to?(:current_page), "Should be a paginated collection"
  end
end