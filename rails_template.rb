project_name = File.basename(File.expand_path(root))

puts "* Removing public files"
run "rm public/index.html"
run "rm public/favicon.ico"

git :init

freeze!
capify!

puts "* Installing Plugins"
plugin 'restful_authentication', :git => 'git://github.com/quirkey/restful-authentication.git', :submodule => true
plugin 'flashdance', :git => 'git://github.com/quirkey/flashdance.git', :submodule => true
plugin 'annotate_models', :git => 'git://github.com/benaskins/annotate_models.git'
plugin 'shoulda', :git => 'git://github.com/thoughtbot/shoulda.git', :submodule => true
plugin 'jrails', :svn => 'http://ennerchi.googlecode.com/svn/trunk/plugins/jrails'
plugin 'halpers', :git => 'git://github.com/quirkey/halpers.git', :submodule => true

git :submodule => 'update --init'

puts "* Generating authentication"
generate(:authenticated, 'user', 'sessions', '--include-activation', '--aasm', '--shoulda')

file 'app/views/shared/flash.yml', '---'

in_root do
  FileUtils.mkdir_p 'app/observers'
  FileUtils.mkdir_p 'app/mailers'
  FileUtils.mv 'app/models/user_mailer.rb', 'app/mailers/user_mailer.rb'
  FileUtils.mv 'app/models/user_observer.rb', 'app/observers/user_observer.rb'
end

environment "config.active_record.observers = :user_observer"
environment "config.load_paths += %W[\#{Rails.root}/app/mailers \#{Rails.root}/app/observers]"


puts "* Adding gems"
gem 'will_paginate'
gem 'erubis', :lib => 'erubis/helpers/rails_helper', :version => '>=2.6.2'
gem 'fastercsv'
gem 'static_model', :version => '>=0.2.0'
gem 'imanip', :version => '>=0.1.4'
gem 'RedCloth', :version => '>=4.0.3'
gem 'rubyist-aasm', :source => 'http://gems.github.com', :lib => 'aasm'
gem 'thoughtbot-factory_girl', :lib => 'factory_girl', :source => 'http://gems.github.com'

rake 'gems:install', :sudo => true

puts "* Adding .gitignore"
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

puts "* Adding initializers"
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

puts "* Adding factory file"
file 'test/factories.rb', <<-TEXT
require 'factory_girl'

Factory.define(:user) do |u|
  u.login 'aaron'
  u.first_name 'Aaron'
  u.last_name  'Quint'
  u.email {|a| \"\#{a.first_name}.\#{a.last_name}@example.com\" }
  u.password 'test!'
  u.password_confirmation 'test!'
end
TEXT

puts "* Rewriting test_helper"
file 'test/test_helper.rb', <<-TEXT
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'factories'

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  fixtures :all
  
  include AuthenticatedTestHelper
  include QuirkeyTestHelper

end
TEXT

puts "* Adding rakefile"
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

puts "* Running database"
rake 'db:create:all'
rake 'db:sessions:create'
rake 'db:migrate:all' # in quirkey.rake

git :add => '.'
git :commit => "-a -m 'Initial commit'"