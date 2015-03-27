source "https://rubygems.org"
# This should be the same as the version of Ruby you have installed locally
ruby "1.9.3" 


gem 'sinatra'

gem "data_mapper"

#gem 'dm-sqlite-adapter'
gem 'sinatra-authentication'
gem 'sinatra-flash', :git => 'https://github.com/SFEley/sinatra-flash.git'
gem 'dm-core'
gem "chartkick"
gem "groupdate"

gem 'capistrano'

#group :development, :test do
#  gem 'sqlite3'
#  gem 'dm-sqlite-adapter'
#end

group :production do
  gem 'pg'
  gem 'dm-postgres-adapter'
end