project_name = File.basename(File.expand_path(root))

log '* removing'
run "rm public/index.html"
run "rm public/favicon.ico"

git :init

freeze!
capify!

log 'installing', 'plugins'
plugin 'restful_authentication', :git => 'git://github.com/quirkey/restful-authentication.git', :submodule => true
plugin 'flashdance', :git => 'git://github.com/quirkey/flashdance.git', :submodule => true
plugin 'annotate_models', :git => 'git://github.com/benaskins/annotate_models.git'
plugin 'shoulda', :git => 'git://github.com/thoughtbot/shoulda.git', :submodule => true
plugin 'jrails', :svn => 'http://ennerchi.googlecode.com/svn/trunk/plugins/jrails'
plugin 'halpers', :git => 'git://github.com/quirkey/halpers.git', :submodule => true

git :submodule => 'update --init'

use_email = yes?('Use email instead of login for authentication?')
generate(:authenticated, 'user', 'sessions', '--include-activation', '--aasm', '--shoulda', "#{use_email ? '--email' : ''}")

file 'app/views/shared/flash.yml', '---'

in_root do
  log 'creating', 'app/observers'  
  FileUtils.mkdir_p 'app/observers'
  FileUtils.mkdir_p 'app/mailers'
  log 'creating', 'app/mailers'
  FileUtils.mv 'app/models/user_mailer.rb', 'app/mailers/user_mailer.rb'
  FileUtils.mv 'app/models/user_observer.rb', 'app/observers/user_observer.rb'
end

environment "config.active_record.observers = :user_observer"
environment "config.load_paths += %W[\#{Rails.root}/app/mailers \#{Rails.root}/app/observers]"

gem 'will_paginate'
# Erubis is broken with edge rails
# gem 'erubis', :lib => 'erubis/helpers/rails_helper', :version => '>=2.6.2'
gem 'fastercsv'
gem 'static_model', :version => '>=0.2.0'
gem 'imanip', :version => '>=0.1.4'
gem 'RedCloth', :version => '>=4.0.3'
gem 'rubyist-aasm', :source => 'http://gems.github.com', :lib => 'aasm'

rake 'gems:install', :sudo => true

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


log 'rewriting', 'test_helper'
file 'test/test_helper.rb', <<-TEXT
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  fixtures :all
  
  include AuthenticatedTestHelper
  include QuirkeyTestHelper

end
TEXT

rakefile "#{project_name}.rake", <<-TEXT
namespace :#{project_name} do
  task :load_env => [:environment]
  
  namespace :clean do
    desc 'Nightly maitenence task for #{project_name}'
    task :nightly => ['#{project_name}:load_env', 'db:clear_sessions'] do
      
    end
  end
end
TEXT

file 'app/views/layout/main.html.erb', <<-TEXT
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>

	<title>#{project_name}</title>
	
	<%= javascript_include_tag :defaults %>
	<%= stylesheet_link_tag '#{project_name}' %>
</head>

<body>
  <%= yield =>
</body>
</html>
TEXT

file "public/stylesheets/#{project_name}.css", <<-TEXT
/* #{project_name}.css / */

TEXT

file 'app/controllers/application_controller.rb', <<-TEXT
class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  
  helper :all 
  protect_from_forgery

  filter_parameter_logging :password
end
TEXT

log 'running', 'database'
rake 'db:create:all'
rake 'db:sessions:create'
rake 'db:migrate:all' # in quirkey.rake

git :add => '.'
git :commit => "-a -m 'Initial commit'"