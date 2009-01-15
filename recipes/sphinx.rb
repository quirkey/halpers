namespace :sphinx do
  desc "Create sphinx.yml in shared/config" 
  task :create_config do
    database_configuration = <<-EOF
#{rails_env}:
  config_file: #{shared_path}/config/sphinx.#{rails_env}.conf
    EOF

    run "mkdir -p #{deploy_to}/#{shared_dir}/config" 
    run "mkdir -p #{deploy_to}/#{shared_dir}/db/sphinx" 
    put database_configuration, "#{deploy_to}/#{shared_dir}/config/sphinx.yml" 
  end

  desc "Link in the production sphinx.yml" 
  task :symlink_config do
    run "ln -nfs #{deploy_to}/#{shared_dir}/config/sphinx.yml #{release_path}/config/sphinx.yml" 
  end


  desc "Re-establish symlinks"
  task :symlink do
    symlink_config
    run <<-CMD
    rm -fr #{release_path}/db/sphinx &&
    ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx
    CMD
  end

  desc "Stop the sphinx server"
  task :stop , :roles => :app do
    run "cd #{current_path} && rake thinking_sphinx:stop RAILS_ENV=#{rails_env} --trace"
  end

  desc "Start the sphinx server" 
  task :start, :roles => :app do
    run "cd #{current_path} && rake thinking_sphinx:start RAILS_ENV=#{rails_env} --trace"
  end
  
  task :index, :roles => :app do
    run "cd #{current_path} && rake thinking_sphinx:index RAILS_ENV=#{rails_env} --trace"
  end

  desc "Restart the sphinx server"
  task :restart, :roles => :app do
    run "cd #{current_path} && rake thinking_sphinx:restart RAILS_ENV=#{rails_env} --trace"
  end  

  desc "Configure the sphinx server for the current Rails Env"
  task :configure, :roles => :app do
    run "cd #{current_path} && rake thinking_sphinx:configure RAILS_ENV=#{rails_env} --trace"
  end

end