%w{quirkey_helper quirkey_test_helper quirkey_extensions deep_hash super_hash}.each do |lib|
  require File.join(File.dirname(__FILE__), 'lib', lib)
end

if defined?(ActionView::Base)
  ::ActionView::Base.send :include, QuirkeyHelper
end