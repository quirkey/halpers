
class ActiveRecord::Base
  def self.update_sortable_tree(param, position_param = :position)
    sort = {}
    param.each do |g_position,group|
      # group = "6"=>{"id"=>"4"} | "4"=>{"0"=>{"id"=>"1"},"id"=>"9"}
      group.each_recursive do |key,second_group,parent_group|
        if key == "id"
          sort[second_group] = {position_param => g_position.to_i + 1, :parent_id => nil}
        else
          sort[second_group[:id]] = {position_param => key.to_i + 1, :parent_id => parent_group[:id]}
        end
      end
    end
    self.update(sort.keys,sort.values)
  end
  
  def self.update_sortable(param, position_param = :position)
    sortable = {}
    param = param.values if param.is_a?(Hash)
    param.each_with_index do |item_id, position|
      sortable[item_id] = {position_param => (position.to_i + 1)}
    end
    self.update(sortable.keys, sortable.values)
  end
  
  def has_errors?
    errors.length > 0
  end
  # def time_stamp
  #     TzTime.zone.utc_to_local(created_at.utc).strftime('%B %d, %Y') + " at " + TzTime.zone.utc_to_local(created_at.utc).strftime('%I:%M %p') if self.respond_to?(:created_at)
  #   end
end

class Hash
  def each_recursive(&block)
    self.each do |key,val|
      val.each_recursive(&block) if val.is_a?(Hash)
      yield(key,val,self)
    end
  end
end

class Array
  def to_hash
    h = {}
    self.each_with_index do |val, i|
      h[i] = val
    end
    h
  end
  
  def to_range(&block)
    min = self.min(&block)
    max = self.max(&block)
    Range.new(min, max)
  end
end

SAFE_URL_CHARS = 'a-z0-9\-\_'
SAFE_URL_VALIDATION_PATTERN = Regexp.new("\\A[#{SAFE_URL_CHARS}]+\\Z")
SAFE_URL_PATTERN = Regexp.new("[#{SAFE_URL_CHARS}]+")

module ActiveSupport::CoreExtensions::String::Inflections
  def urlify
    self.downcase.gsub(/\ /,'_').gsub(Regexp.new("[^#{SAFE_URL_CHARS}]"),'')[0..40]
  end
end