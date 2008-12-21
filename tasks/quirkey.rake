namespace :db do
  namespace :migrate do
    desc ' Migrates one revision back then up to the current version'
    task :downup => [:environment,'db:migrate:back'] do
      ActiveRecord::Migrator.migrate("db/migrate/", nil)
    end
    
    desc 'Runs migrate, test:clone and annotate_models'
    task :all => ['db:migrate', 'db:test:clone', 'annotate_models'] do
    end
  end

  desc 'Clears sessions not updated in the last 24 hours'
  task :clear_sessions => :environment do
    sql = "DELETE from sessions where DATE(updated_at) < DATE('#{1.day.ago.to_s :db}')"
    puts "[#{Time.now}] Executing - #{sql}"
    ActiveRecord::Base.connection.execute(sql)
  end
end


desc "Download a tarball from Github and extract to a shared dir then symlink to vendor/rails"
task :deploy_edge do
  puts "Pulling Rails from github"
  shared      = ENV['SHARED_PATH'] || File.join('..','..','shared')
  shared_path = File.expand_path(shared)
  puts "Shared Path: #{shared_path}"

  rails_path    = File.join(shared_path, 'rails')
  rails_version = ENV['VERSION'] || ENV['REVISION'] || 'v2.1.0'
  export_path   = File.join(rails_path, "rails_#{rails_version}")
  symlink_path  = File.join(RAILS_ROOT, 'vendor','rails')
  puts "Pulling Rails tag: #{rails_version} to #{export_path}"
  remote_revision_path = "http://github.com/rails/rails/tarball/#{rails_version}"
  local_tarball_path = File.join(rails_path, "rails_#{rails_version}.tar.gz")

  unless File.exists?(export_path)
    puts 'Downloading tar from github'
    mkdir_p export_path
    system "curl -L #{remote_revision_path} > #{local_tarball_path}"
    system "cd #{shared_path} && tar -xzf #{local_tarball_path}"
    system "cd #{shared_path} && mv rails-rails-*/* #{export_path}/"
  else
    puts '-> Rails already downloaded and extracted'
  end

  puts 'Symlinking to vendor/rails'
  rm_rf   symlink_path
  ln_s    export_path, symlink_path
  touch "vendor/rails_#{rails_version}"
  puts 'Done'
end

# http://www.thelucid.com/articles/2007/05/16/rails-edge-getting-your-view-extensions-ready-for-edge
namespace :rails do
  namespace :views do
    desc 'Renames all .rhtml views to .html.erb, .rjs to .js.rjs, .rxml to .xml.builder and .haml to .html.haml'
    task :rename do
      Dir.glob('app/views/**/*.rhtml').each do |file|
        puts `git mv #{file} #{file.gsub(/\.rhtml$/, '.html.erb')}`
      end

      Dir.glob('app/views/**/*.rjs').each do |file|
        puts `git mv #{file} #{file.gsub(/\.rjs$/, '.js.rjs')}`
      end

      Dir.glob('app/views/**/*.rxml').each do |file|
        puts `git mv #{file} #{file.gsub(/\.rxml$/, '.xml.builder')}`
      end

      Dir.glob('app/views/**/*.haml').each do |file|
        puts `git mv #{file} #{file.gsub(/\.haml$/, '.html.haml')}`
      end
    end
  end
  
  task :copy_model => :environment do  
    models     = ENV['MODELS'].split(',')
    from       = File.expand_path(ENV['FROM'])
    to         = File.expand_path(ENV['TO'])

    raise "MODELS FROM TO" unless models && from && to

    files = []
    models.each do |model_name|
    files.concat(["app/models/#{model_name.underscore}.rb",
                  "test/fixtures/#{model_name.tableize}.yml",
                  "test/unit/#{model_name.underscore}_test.rb"])
    end

    files.each do |file|
      from_file, to_file = File.join(from, file), File.join(to, file)
      puts "Copying From #{from_file} to #{to_file}"
      begin
        FileUtils.cp(from_file, to_file)
      rescue => e
        warn e
      end
    end
  end 

  task :copy_controller => :environment do
    controllers= ENV['CONTROLLERS'].split(',')
    from       = File.expand_path(ENV['FROM'])
    to         = File.expand_path(ENV['TO'] || '')

    raise "CONTROLLERS FROM TO" unless controllers && from && to

    files = []
    controllers.each do |controller_name|
    files.concat(["app/controllers/#{controller_name}_controller.rb",
                  "test/functional/#{controller_name}_controller_test.rb"])
                  Dir[File.join(from, 'app', 'views', controller_name, '**')].each do |file|
                    files << (file.gsub(from, ''))
                  end
    end

    files.each do |file|
      from_file, to_file = File.join(from, file), File.join(to, file)
      puts "Copying From #{from_file} to #{to_file}"
      begin
        FileUtils.mkdir_p(File.dirname(to_file))
        FileUtils.cp(from_file, to_file)
      rescue => e
        puts e
      end
    end
  end
  
end