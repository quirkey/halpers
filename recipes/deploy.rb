namespace :deploy do
  desc "run rake gems:install"
  task :gems do
    run "cd #{current_path} && #{sudo} rake gems:install RAILS_ENV=#{rails_env} --trace"
  end

  desc 'own the whole directory'
  task :own do
    sudo "chown -R #{user} #{deploy_to}"
  end

  desc "Deploy the edge version of rails via symlink"
  task :deploy_rails_edge, :roles => :app, :except => {:no_release => true} do
    run <<-CMD
    cd #{release_path} && 
    rake rails:freeze:edge RELEASE=#{rails_version}
    CMD
  end
  
end
