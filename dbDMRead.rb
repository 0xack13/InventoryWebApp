require "rubygems"
require "sinatra"
require 'sinatra/flash'
require "data_mapper"
require 'json'

require 'fileutils'

include FileUtils::Verbose



oldverb = $VERBOSE; $VERBOSE = nil
require 'iconv'
$VERBOSE = oldverb

use Rack::MethodOverride
set :method_override, true

configure do
  enable :method_override
end

enable :sessions


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
          flash[:notice] = "Record inserted correctly!"

        redirect '/'
  else
        {:inv => @inv, :status => "failure"}.to_json
  end
end

#update	
put "/:id/save" do
  @inv = Inv2.first(:id => params[:id])
  @inv.code = params[:code]
  @inv.name = params[:name]
  @inv.size = params[:size]
  @inv.quantity = params[:quantity]
  @inv.type = params[:type]
  @inv.location = params[:location]
  @inv.picture = params[:picture]
  tempfile = params[:picture][:tempfile] 
  filename = params[:picture][:filename] 
  cp(tempfile.path, "./public/uploads/#{filename}")
  if @inv.save
        {:inv => @inv, :status => "success"}.to_json
        flash[:notice] = "Saved correctly!"
        redirect '/'
  else
        {:inv => @inv, :status => "failure"}.to_json
  end
end

#delete
get "/:id/delete" do
    #@inv = Inv2.find(params[:id])
    @inv = Inv2.first(:id => params[:id])
    if @inv.destroy
        {:inv => @inv, :status => "success"}.to_json
        flash[:notice] = "The record was deleted.."
        redirect '/'
    else
        {:inv => @inv, :status => "failure"}.to_json
    end
end

#find
get "/:id/edit" do
    #@inv = Inv2.find(params[:id])
    @inv = Inv2.all
    @sinv = Inv2.first(:id => params[:id])
    #@inv.to_json
    erb :form
end

get "/" do
  #@posts = Post.all()
  #Inv2.get(1).picture
  @inv = Inv2.all
  flash[:notice] = "Logged in at #{Time.now}."
  erb :index
end


__END__
@@layout
<% title="Inventory Management" %>
<!doctype html>

<html class=''>
<head><meta charset='UTF-8'><meta name="robots" content="noindex">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
  <link href="<%= url("style.css")%>" media="all" rel="stylesheet" type="text/css" />
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap-theme.min.css">
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
  <style type="text/css">
      .bs-example{
        margin: 20px;
      }
  </style>
  <script type='text/javascript'>//<![CDATA[ 
    $(window).load(function(){
      $('#click').click(function()
      {
          $("#panel").animate({width:'toggle'},500);       
      });
      $('#editLink').click(function()
      {
        console.log("link clicked!");
          $("#panel").animate({width:'toggle'},500);       
      });
    });//]]>  
  </script>
</head>
<body>
<div id='header'></div>  

<div id='container'>
  <div id='click'></div>
  <div class='signup form-group' id='panel'>
    <%= yield %>
  </div>
  <div class='whysign'>
    <div id='flash' class='notice'>
     <a class="close" data-dismiss="alert">&#215;</a>
     <p><%= flash[:notice] %></p>
    </div>
    <h1>Inventory Management v1</h1>
    <p>Stock Summary</p>
      <table class="table table-striped"  style='overflow:hidden;table-layout:fixed;width:100%'>
        <thead>
            <tr>
                <th>Row</th>
                <th>Code</th>
                <th>Name</th>
                <th>Size</th>
                <th>Quantity</th>
                <th>Type</th>
                <th>Location</th>
                <th>Picture</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
          <% @inv.each_with_index do |inv, index| %>
            <tr>
                <td><%= index += 1 %></td>
                <td><%= inv[:code] %></td>
                <td><%= inv[:name] %></td>
                <td><%= inv[:size] %></td>
                <td><%= inv[:quantity] %></td>
                <td><%= inv[:type] %></td>
                <td><%= inv[:location] %></td>
                <td><img class="thumbnail" src="../public/<%= inv[:picture] %>"><%= inv[:picture] %></td>
                <td><a id="editLink" onclick="console.log('clicked!!!');" href="/<%= inv[:id] %>/edit">Edit</a> | <a href="/<%= inv[:id] %>/delete" onclick="return confirm('are you sure?')">Delete</a></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    <p>Learn: 
      <span>In</span>
      <span>Out</span>
      <span>All</span>
    </p>
  </div>
</div>


</body>

</html>


@@index
<form action="/new" type="post" enctype="multipart/form-data">
       <input type='text' name="code" placeholder='Code:'  />
       <input type='text' name="name" placeholder='Name:'  />
       <select class="form-control" name="size">
        <option value="" disabled selected>Size</option>
        <option value="A3">A3</option>
        <option value="A4">A4</option>
        <option value="XL">XL</option>
        <option value="XXL">XXL</option>
      </select>
       <input type='text' name="quantity" placeholder='Quantity:'  />
       <select class="form-control" name="type">
        <option value="" disabled selected>Type</option>
        <option value="Catalogue">Catalogue</option>
        <option value="Flyer">Flyer</option>
        <option value="Sticker">Sticker</option>
        <option value="Poster">Poster</option>
        <option value="Folder">Folder</option>
      </select>
      <select class="form-control" name="location">
        <option value="" disabled selected>Location</option>
        <option value="JED">JED</option>
        <option value="RYD">RYD</option>
        <option value="DMM">DMM</option>
        <option value="MAK">MAK</option>
        <option value="DAH">DAH</option>
      </select>
       <input type="file" name="picture" class="form-control">
       <input type='submit' placeholder='SUBMIT' value="Add new Record" />
     </form>

@@form
 <form action="/<%= @sinv.id %>/save" method="POST">
        <input name="_method" type="hidden" value="PUT" />
       <input type='text' name="code" placeholder='Code:' value='<%= @sinv.code %>'  />
       <input type='text' name="name" placeholder='Name:' value='<%= @sinv.name %>' />
      <select class="form-control" name="size">
          <% ["A3", "A4", "XL", "XXL"].each do |selectInvValue| %>
            <option <%= 'selected="selected"' if selectInvValue == @sinv.size %> value="<%= selectInvValue %>"><%= selectInvValue %></option>
          <% end %>
      </select>
       <input type='text' name="quantity" placeholder='Quantity:' value='<%= @sinv.quantity %>' />
      <select class="form-control" name="type">
          <% ["Catalogue", "Flayer", "Sticker", "Poster", "Folder"].each do |selectInvValue| %>
            <option <%= 'selected="selected"' if selectInvValue == @sinv.type %> value="<%= selectInvValue %>"><%= selectInvValue %></option>
          <% end %>
      </select>
      <select class="form-control" name="location">
          <% ["JED", "RYD", "DMM", "MAK", "DAH"].each do |selectInvValue| %>
            <option <%= 'selected="selected"' if selectInvValue == @sinv.location %> value="<%= selectInvValue %>"><%= selectInvValue %></option>
          <% end %>
      </select>
       <input type="file" name="picture" class="form-control">
       <input type='submit' placeholder='Save Changes' value="Save Changes" />
     </form>