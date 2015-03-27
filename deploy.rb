# deploy.rb

set :stages, ["production"]


set :application, 'invman'
set :scm, "git"
set :repository, "file://." #'protocol://repository/url'

role :web, 'localhost'
role :app, 'localhost'
role :db, 'localhost'



set :deploy_to, '/Users/Saleh/src/0xack13/invman'

namespace :deploy do
	task :start do ; end
  	task :stop do ; end
	task :restart, :roles => [:web, :app, :db] do
		run "ls"
	    run "#{deploy_to}/current/config/restart.sh"
	end

	task :restart1 do
		run "ls"
	    #run "#{deploy_to}/current/config/restart.sh"
	end
end

namespace :deploy do
  task :ping do
    system "curl --silent #{fetch(:ping_url)}"
  end
end
