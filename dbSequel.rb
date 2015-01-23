require 'rubygems' # may not be needed, depending on platform
require 'sinatra'
require 'active_record'

class Article < ActiveRecord::Base
end

get '/' do
  Article.establish_connection(
    :adapter => "sqlite3",
    :database => "hw.db"
  )
  Article.first.title
end
