require 'rubygems'
require 'sinatra'
require 'sequel'
require 'sqlite3'

DB = Sequel.sqlite

DB.create_table :links do
    primary_key :id
    varchar :title
    varchar :link
end

class Link < Sequel::Model; end

get '/' do
  @links = Link.all
    haml :links
    end

