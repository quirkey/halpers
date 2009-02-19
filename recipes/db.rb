namespace :db do
  desc "Create database.yml in shared/config" 
  task :create_config do
    database_configuration = <<-EOF
#{rails_env}:
  database: #{environment_database}
  adapter: mysql
  host: #{environment_dbhost}
  username: #{dbuser}
  password: #{dbpass}
  EOF

    run "mkdir -p #{deploy_to}/#{shared_dir}/config" 
    put database_configuration, "#{deploy_to}/#{shared_dir}/config/database.yml" 
  end

  desc "Link in the production database.yml" 
  task :symlink_config do
    run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml" 
  end

  task :backup_name, :only => { :primary => true } do
    now = Time.now
    run "mkdir -p #{shared_path}/db_backups"
    set :backup_time, [now.year,now.month,now.day,now.hour,now.min,now.sec].join('-')
    set :backup_file, "#{shared_path}/db_backups/#{environment_database}-snapshot-#{backup_time}.sql"
  end

  desc "Clone Production Database to Staging Database."
  task :clone_prod_to_staging, :roles => :db, :only => { :primary => true } do
    backup_name
    on_rollback { run "rm -f #{backup_file}" }
    run "mysqldump --add-drop-table -u #{dbuser} -h #{production_dbhost} -p#{dbpass} #{production_database} > #{backup_file}"
    run "mysql -u #{dbuser} -p#{dbpass} -h #{staging_dbhost} #{staging_database} < #{backup_file}"
    run "rm -f #{backup_file}"
  end

  desc "Backup your database to shared_path/db_backups"
  task :dump, :roles => :db, :only => {:primary => true} do
    backup_name
    run "mysqldump --add-drop-table -u #{dbuser} -h #{environment_dbhost} -p#{dbpass} #{environment_database} | bzip2 -c > #{backup_file}.bz2"
  end

  desc "Download production database and suck it in to local development"
  task :clone_to_local, :roles => :db, :only => {:primary => true} do
    backup_name
    local_file = "db/latest_production_#{backup_time}.sql"
    dump
    get "#{backup_file}.bz2", "#{local_file}.bz2"
    `rm -f #{local_file}`
    `bunzip2 #{local_file}.bz2`
    `mysql -u root #{application}_development < #{local_file}`
  end
  
end