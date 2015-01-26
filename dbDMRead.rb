require "rubygems"
require "sinatra"
require "data_mapper"
require 'json'


oldverb = $VERBOSE; $VERBOSE = nil
require 'iconv'
$VERBOSE = oldverb

# need install dm-sqlite-adapter
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/data.dat")

class Inv2
  include DataMapper::Resource
  property :id, Serial, :serial => true
  property :code, String
  property :name, String
  property :size, String
  property :quantity, Integer
  property :type, String
  property :location, String
  property :picture, String
  #property :created_at, DateTime
end

# Perform basic sanity checks and initialize all relationships
# Call this when you've defined all your models
DataMapper.finalize

# automatically create the post table
Inv2.auto_upgrade!


get "/" do
  #@posts = Post.all()
  Inv2.get(1).picture
end

get "/new" do
  #@posts = Post.all()
  #Inv2.get(1).picture
  @inv = Inv2.new
  @inv.code = params[:code]
  @inv.name = params[:name]
  @inv.size = params[:size]
  @inv.quantity = params[:quantity]
  @inv.type = params[:type]
  @inv.location = params[:location]
  @inv.picture = params[:picture]
  if @inv.save
        {:inv => @inv, :status => "success"}.to_json
  else
        {:inv => @inv, :status => "failure"}.to_json
  end
  
end