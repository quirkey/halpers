run "rm public/index.html"

git :init

freeze!
capify!

plugin 'restful_authentication', :git => 'git://github.com/technoweenie/restful-authentication.git'
plugin 'flashdance', :git => 'git://github.com/quirkey/flashdance.git', :submodule => true
plugin 'annotate_models', :git => 'git://github.com/benaskins/annotate_models.git'
plugin 'shoulda', :git => 'git://github.com/thoughtbot/shoulda.git', :submodule => true

git :submodule => 'update --init'

gem 'will_paginate'
gem 'erubis', :lib => 'erubis/helpers/rails_helper', :version => '>=2.6.2'
gem 'fastercsv'
gem 'static_model', :version => '>=0.2.0'
gem 'imanip', :version => '>=0.1.4'
gem 'RedCloth', :version => '>=4.0.3'
gem 'rubyist-aasm', :source => 'http://gems.github.com', :lib => 'aasm'

rake 'gems:install'

generate(:authenticated, 'users', 'sessions', '--include-activation', '--aasm')

file '.gitignore', <<-TEXT
tmp/*
log/*
db/latest*
.DS_Store
vendor/rails*
*.svn*
public/assets*
public/test_assets*
*.tmproj
db/sphinx
TEXT

# jQuery
file 'public/javascripts/jquery-min.js' do
  open('http://jqueryjs.googlecode.com/files/jquery-1.2.6.min.js').read
end

initializer 'date_formats.rb', <<-TEXT
Time::DATE_FORMATS[:published] = '%B %e, %Y'
Time::DATE_FORMATS[:event_date] = '%B %e'
Time::DATE_FORMATS[:comment] = '%B %e, %Y at %l:%M%p'

class Time
  
  def am_pm
    hour < 12 ? 'AM' : 'PM'
  end
end

class DateTime
  
  def to_i
    to_time.to_i
  end
  
end
TEXT

rake "db:migrate"

git :add => '.'
git :commit => "-a -m 'Initial commit'"