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
  property :title, String
  property :desc, String
end

Post.auto_migrate!
first_post = Post.new
first_post.title = "First!"
first_post.desc = "Hello!"
first_post.save

get "/" do
  Post.get(1).title
  Post.get(1).desc
end
