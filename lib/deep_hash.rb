module DeepHash

  def deep_value(key_array)
    value = self
    Array(key_array).each do |key|
      value = value.fetch(key, nil) 
    end
    value
  rescue NoMethodError
    nil
  end
  
  def deep_merge(other_hash)
    self.merge(other_hash) do |key, old_val, new_val|
      self[key] = (old_val.is_a?(Hash) && new_val.is_a?(Hash)) ? old_val.deep_merge(new_val) : new_val
    end
  end
  
  def deep_find_and_replace(with_value, &block)
    self.each do |key,val|
      if yield(val)
        self[key] = with_value
      else
        self[key].deep_find_and_replace(with_value, &block) if self[key].is_a?(Hash)
      end
    end
    self
  end

  def deep_each(&block)
    self.each do |key, val|
      if self[key].is_a?(Hash)
        self[key].deep_each(&block)
      end
      yield(self, key, val)
    end
  end

end
