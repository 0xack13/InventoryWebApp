require "rubygems"
require "sinatra"
require "data_mapper"

oldverb = $VERBOSE; $VERBOSE = nil
require 'iconv'
$VERBOSE = oldverb

DataMapper.setup(:default, "sqlite3::memory:")

class Post
  include DataMapper::Resource
  property :id,    Serial, :serial => true
  property :item, String
  property :desc, String
  property :loc, String
  property :qty, String 
end

Post.auto_migrate!
first_post = Post.new
first_post.item = "First!"
first_post.desc = "Hello!"
first_post.save

get "/" do
  Post.get(1).desc
end
