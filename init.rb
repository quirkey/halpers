%w{quirkey_helper quirkey_test_helper quirkey_extensions}.each do |lib|
  require File.join(File.dirname(__FILE__), 'lib', lib)
end

::ActionView::Base.send :include, QuirkeyHelper