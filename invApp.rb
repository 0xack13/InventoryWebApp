require "rubygems"
require "sinatra"
require 'sinatra/flash'
require "data_mapper"
require 'json'
require 'find'


require 'fileutils'

include FileUtils::Verbose

set :bind, '0.0.0.0'


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
  @inv.picture.sub!(/\//, '');
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
  @inv.picture.sub!(/\//, '');
  #tempfile = params[:picture][:tempfile] 
  #filename = params[:picture][:filename] 
  #cp(tempfile.path, "./public/uploads/#{filename}")
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
    @files = Dir.glob("public/*.jpg")
    #@inv.to_json
    erb :edit
end

get "/" do
  #@posts = Post.all()
  #Inv2.get(1).picture
  @inv = Inv2.all
  @files = Dir.glob("public/*.jpg")
  flash[:notice] = "Logged in at #{Time.now}."
  erb :default
end


get "/add" do
  @inv = Inv2.all
  @files = Dir.glob("public/*.jpg")
  erb :add
end


get "/upload" do
  @inv = Inv2.all
  erb :upload
end
 
post '/save_image' do
  @inv = Inv2.all
  @filename = params[:file][:filename]
  file = params[:file][:tempfile]
 
  File.open("public/#{@filename}", 'wb') do |f|
    f.write(file.read)
  end
  
  erb :show_image
end

get '/list' do
  @inv = Inv2.all
  @files = Dir.glob("public/*.jpg")
  #p files
  #files = Dir['public/*']
  #@ary = ['a','b','c']
  #p files
  erb :list
 
end


get '/media' do
  @inv = Inv2.all
  @files = Dir.glob("public/*.jpg")
  #p files
  #files = Dir['public/*']
  #@ary = ['a','b','c']
  #p files
  erb :media
 
end



# get all images
get '/debug/posts/images/' do
  puts '>> debug > posts > images > get'

  all_images = Array.new

    # build substitute prefix path 
  uri = URI(request.url)
  prefix ='http://' + uri.host
  if request.port
    prefix += ':' + request.port.to_s
  end
  prefix += '/content/'

  begin
    content_type :json
        # get list of images
    pics = Dir['public/*.jpg']
    pics.map { |pic|
            # build hash for use with tinyMCE
      pic.split('/')
      pic_hash = {:title => File.basename(pic).to_s, :value => prefix + File.basename(pic).to_s}
      all_images.push(pic_hash)
    }

        # convert to json
    pic_json = JSON.generate(all_images)    
    body(pic_json)
  rescue Sequel::Error => e
    puts e.message
    status(400).to_json
  end
end

__END__
@@layout
<% title="Inventory Management" %>
<!doctype html>

<html class=''>
<head>
  <meta charset='UTF-8'><meta name="robots" content="noindex">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
  <link href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css" rel="stylesheet">
        
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
  <link href="<%= url("style.css")%>" media="all" rel="stylesheet" type="text/css" />
  
  <script type='text/javascript'>//<![CDATA[ 
    $(window).load(function(){
      if (navigator.userAgent.match(/IEMobile\/10\.0/)) {
  var msViewportStyle = document.createElement('style');
  msViewportStyle.appendChild(
    document.createTextNode(
      '@-ms-viewport{width:auto!important}'
    )
  );
  document.querySelector('head').appendChild(msViewportStyle)
}
      $('#click').click(function()
      {
          $("#panel").animate({width:'toggle'},500);       
      });
      $('#editLink').click(function()
      {
        console.log("link clicked!");
          $("#panel").animate({width:'toggle'},500);       
      });
      
      $("img").click(function() {
        $("img").not(this).removeClass("hover");
        $(this).toggleClass("hover");
        var imgs = $("img.hover").attr('src');    
        //alert('there are ' + imgs + ' images selected: ' );
        var element = document.getElementById("picture");
        element.value = $("img.hover").attr('src');
        console.log(element.value);
      });

      $("#btn").click(function() {
        //$("img.hover").attr('src').filename();
        //$("img.hover").attr('src');
        //var imgs = $("img.hover").length;    
        var imgs = $("img.hover").attr('src');    
        alert('there are ' + imgs + ' images selected: ' );
        var element = document.getElementById("picture");
        element.value = $("img.hover").attr('src');
      });
      function setValue(){
          //document.sampleForm.total.value = 100;
          //document.forms["picture"].submit();
          var element = document.getElementById("picture");
          element.value = $("img.hover").attr('src');
      }
    });//]]>  
  </script>
</head>
<body>
<ul class="navigation">
  <li class="nav-item"><a href="/"><span class="glyphicon glyphicon-home"></span>&nbsp;Home</a></li>
  <li class="nav-item"><a href="/add"><span class="glyphicon glyphicon-plus"></span>&nbsp;New</a></li>
  <li class="nav-item"><a href="/upload"><span class="glyphicon glyphicon-upload"></span>&nbsp;Upload</a></li>
  <li class="nav-item"><a href="/media"><span class="glyphicon glyphicon-folder-open"></span>&nbsp;Media</a></li>

  <li class="nav-item"><a href="mailto:support@support.com"><span class="glyphicon glyphicon-envelope"></span>&nbsp;Support</a></li>
</ul>

<input type="checkbox" id="nav-trigger" class="nav-trigger" />
<label for="nav-trigger"></label>

<div class="site-wrap">
      <%= yield %>
</div>

</body>
</html>

@@default
<hr class="colorgraph">
 <h1>Inventory Management v1</h1>
 <h3>Simple stock management solution</h3>
<div class="table-responsive">
      <table class="responsive-table responsive-table-input-matrix">
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
                <td><img class="thumbnail" src="/<%= inv[:picture] %>" title="<%= inv[:picture] %>"></td>
                <td><a id="editLink" onclick="console.log('clicked!!!');" href="/<%= inv[:id] %>/edit">Edit</a> | <a href="/<%= inv[:id] %>/delete" onclick="return confirm('are you sure?')">Delete</a></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
</div>




@@add
 <div class="container">

<div class="row">
    <div class="col-xs-12 col-sm-8 col-md-6 col-sm-offset-2 col-md-offset-3">
<form action="/new" type="post" enctype="multipart/form-data">
   <h2>New
   <small>Add a new stock item</small>
 </h2>
      <hr class="colorgraph">
      <div class="row">
        <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
              <input type='text' class="form-control input-lg" name="code" placeholder='Code:' class="form-control input-lg"  />
          </div>
        </div>
        <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
            <input type='text' name="name" placeholder='Name:' class="form-control input-lg" />
          </div>
        </div>
      </div>
      
      <div class="row">
        <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
              <select class="form-control input-lg" name="size">
                <option value="" disabled selected>Size</option>
                <option value="A3">A3</option>
                <option value="A4">A4</option>
                <option value="XL">XL</option>
                <option value="XXL">XXL</option>
              </select>
            </div>
          </div>
            <div class="col-xs-6 col-sm-6 col-md-6">
               <div class="form-group">
                <input type='text' name="quantity" placeholder='Quantity:'  class="form-control input-lg" />
               </div>
             </div>
           </div>

      <div class="row">
        <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
               <select class="form-control input-lg" name="type">
                <option value="" disabled selected>Type</option>
                <option value="Catalogue">Catalogue</option>
                <option value="Flyer">Flyer</option>
                <option value="Sticker">Sticker</option>
                <option value="Poster">Poster</option>
                <option value="Folder">Folder</option>
              </select>
            </div>
          </div>
           <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
              <select name="location" class="form-control input-lg">
                <option value="" disabled selected>Location</option>
                <option value="JED">JED</option>
                <option value="RYD">RYD</option>
                <option value="DMM">DMM</option>
                <option value="MAK">MAK</option>
                <option value="DAH">DAH</option>
              </select>
            </div>
          </div>
        </div>
        <div>
          <ul>
            <% @files.each { |x| %>
              <li><img src="<%= x.sub!(/public\//, '/') %>" style="width:180px; height:180px;"/></li>
            <% } %>
          </ul>
        </div>
        <br>
        <input type="hidden" name="picture" id="picture" value="">
              <hr class="colorgraph">

       <input type='submit' placeholder='SUBMIT' value="Add new Record" class="btn btn-primary btn-block btn-lg" />
     </form>
   </div>
 </div>

@@edit
<div class="container">

<div class="row">
    <div class="col-xs-12 col-sm-8 col-md-6 col-sm-offset-2 col-md-offset-3">
 <form action="/<%= @sinv.id %>/save" method="POST">
   <h2>Edit
   <small>an existing stock item</small>
 </h2>
      <hr class="colorgraph">
      <div class="row">
        <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
        <input name="_method" type="hidden" value="PUT" />
       <input type='text' name="code" class="form-control input-lg" placeholder='Code:' value='<%= @sinv.code %>'  />
        </div>
        </div>
        <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
       <input type='text' name="name" class="form-control input-lg" placeholder='Name:' value='<%= @sinv.name %>' />
          </div>
        </div>
      </div>

       <div class="row">
        <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
      <select name="size" class="form-control input-lg">
          <% ["A3", "A4", "XL", "XXL"].each do |selectInvValue| %>
            <option <%= 'selected="selected"' if selectInvValue == @sinv.size %> value="<%= selectInvValue %>"><%= selectInvValue %></option>
          <% end %>
      </select>
      </div>
        </div>
        <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
       <input type='text' name="quantity" class="form-control input-lg" placeholder='Quantity:' value='<%= @sinv.quantity %>' />
     </div>
   </div>
 </div>
 <div class="row">
 <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
      <select class="form-control input-lg" name="type">
          <% ["Catalogue", "Flayer", "Sticker", "Poster", "Folder"].each do |selectInvValue| %>
            <option <%= 'selected="selected"' if selectInvValue == @sinv.type %> value="<%= selectInvValue %>"><%= selectInvValue %></option>
          <% end %>
      </select>
      </div>
        </div>
        <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
      <select class="form-control input-lg" name="location">
          <% ["JED", "RYD", "DMM", "MAK", "DAH"].each do |selectInvValue| %>
            <option <%= 'selected="selected"' if selectInvValue == @sinv.location %> value="<%= selectInvValue %>"><%= selectInvValue %></option>
          <% end %>
      </select>
    </div>
  </div>
</div>
<!-- <input type="file" name="picture" class="form-control">-->
        <a href="#" id="btn">Selected image:</a>
         <img class="thumbnail" src="/<%= @sinv.picture %>">
        <hr>
      <div>
          <ul>
            <% @files.each { |x| %>
              <li><img src="<%= x.sub!(/public\//, '/') %>" title="<%= x.sub!(/\//, '') %>"  style="width:180px; height:180px;"/></li>
            <% } %>
          </ul>
        </div>
        <hr class="colorgraph">
        <input type="hidden" name="picture" id="picture" value="">
        <input type='submit' placeholder='Save Changes' value="Save Changes" class="btn btn-primary btn-block btn-lg" />
     </form>
</div>
</div>
</div>

@@upload
 <div class="container">
  <div class="row">
    <div class="col-xs-12 col-sm-8 col-md-6 col-sm-offset-2 col-md-offset-3">
        <form action="/save_image" method="POST" enctype="multipart/form-data">
          <div class="row">
          <hr class="colorgraph">
           <h2>Upload <small>a new image to your gallery</small></h2>
           </div>
                <div class="row">
                  <div class="col-xs-6 col-sm-6 col-md-6">
                    <div class="form-group">
                      <input type="file" name="file" class="form-control input-lg">
                    </div>
                  </div>
                  <div class="col-xs-6 col-sm-6 col-md-6">
                      <div class="form-group">
                      <input type="submit" value="Upload image" class="btn btn-primary btn-block btn-lg">
                    </div>
                  </div>
                    </div>
                  </div>
                </div>

        </form>
      </div>
    </div>
  </div>

@@show_image
<div class="container">
  <div class="row">
    <div class="col-xs-12 col-sm-8 col-md-6 col-sm-offset-2 col-md-offset-3">
      <h1>Uploaded Image</h1>
      <img src="./<%= @filename %>" />
    </div>
  </div>
</div>

@@media
<div class="container">

<div class="row">
    <div class="col-xs-12 col-sm-8 col-md-6 col-sm-offset-2 col-md-offset-3">
 <form action="/" method="POST">
   <h2>Media
   <small>Delete existing images</small>
 </h2>
      <div>
          <ul>
            <% @files.each { |x| %>
              <li><img src="<%= x.sub!(/public\//, '/') %>" title="<%= x.sub!(/\//, '') %>"  style="width:180px; height:180px;"/></li>
            <% } %>
          </ul>
        </div>
        <hr class="colorgraph">
        <input type="hidden" name="picture" id="picture" value="">
        <input type='submit' placeholder='Delete Selected Image' value="Delete Selected Image" class="btn btn-primary btn-block btn-lg" />
     </form>
</div>
</div>
</div>