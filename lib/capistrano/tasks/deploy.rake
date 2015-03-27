set :user, "Saleh" # The user on the VPS server.
set :use_sudo, false
set :deploy_via, :remote_cache
set :pty, true
set :format, :pretty
set :format, :pretty
set :log_level, :debug
set :username, ask('Server username: ', nil)
set :password, ask('Server password: ', nil)
server 'localhost', user: fetch(:username), port: 22, password: fetch(:password), roles: %w{web app db}


namespace :setup do

  desc "Upload database.yml file."
  task :upload_yml do
    on roles(:app) do
      execute "mkdir sales"
      puts "heehe"
      execute :uptime
      #upload! StringIO.new(File.read("config/database.yml")), "#{shared_path}/config/database.yml"
    end
  end

  desc "Upload database.yml file."
  task :hellothere do
    on roles(:app) do
      puts "heehe Abook"
      execute :uptime
      execute "touch sales/test.log"
      #upload! StringIO.new(File.read("config/database.yml")), "#{shared_path}/config/database.yml"
    end
  end

  desc "Seed the database."
  task :seed_db do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: :production do
          execute :rake, "db:seed"
        end
      end
    end
  end

  desc "Symlinks config files for Nginx and Unicorn."
  task :symlink_config do
    on roles(:app) do
      execute "rm -f /etc/nginx/sites-enabled/default"

      execute "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{fetch(:application)}"
      execute "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{fetch(:application)}"
   end
  end

end