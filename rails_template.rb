run "rm public/index.html"

git :init
plugin 'restful_authentication', :git => 'git://github.com/technoweenie/restful-authentication.git'
plugin 'flashdance', :git => 'git://github.com/quirkey/flashdance.git', :submodule => true
plugin 'annotate_models', :git => 'git://github.com/benaskins/annotate_models.git'
plugin 'shoulda', :git => 'git://github.com/thoughtbot/shoulda.git', :submodule => true

gem 'will_paginate'
gem 'erubis', :lib => 'erubis/helpers/rails_helper', :version => '>=2.6.2'
gem 'fastercsv'
gem 'static_model', :version => '>=0.2.0'
gem 'imanip', :version => '>=0.1.4'
gem 'RedCloth', :version => '>=4.0.3'

rake 'gems:install' 
rake "db:migrate"

git :add => '.'
git :commit => "-a -m 'Initial commit'"