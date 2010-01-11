require 'active_support/core_ext/hash'

class SuperHash < HashWithIndifferentAccess
  include DeepHash

  def deep_merge(other_hash)
    self.dup.to_hash.merge(other_hash) do |key, old_val, new_val|
      self[key] = (old_val.is_a?(Hash) && new_val.is_a?(Hash)) ? old_val.deep_merge(new_val) : new_val
    end
  end  
  
  def [](key)
    superify(super)
  end
  
  def self.superify(val)
    if val.is_a?(Hash) && !val.is_a?(SuperHash)
      SuperHash.new(val)
    elsif val.is_a?(Array)
      val.collect {|f| superify(f) }
    else
      val
    end
  end
  
  def superify(val)
    self.class.superify(val)
  end
  
  private
  def method_missing(m,*a)
    if m.to_s =~ /\?$/ && self.has_key?(m.to_s[0...-1])
      return !!self[m.to_s[0...-1]]
    end
    if m.to_s =~ /=$/
      self[$`] = a[0]
    elsif a.empty?
      self[m.to_s]
    else
      super
    end
  end
    
end