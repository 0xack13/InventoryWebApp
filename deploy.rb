# deploy.rb

set :application, "app_name"
set :repository,  "/Path/to/local/git/repo/.git"
set :local_repository, "/Path/to/local/git/repo/.git"
set :scm, :git
set :deploy_via, :copy
