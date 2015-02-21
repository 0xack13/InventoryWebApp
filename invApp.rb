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
  property :status, String
  property :picture, String
  property :created_at, DateTime

  has n, :transfer
end

class Transfer
  include DataMapper::Resource
  property :tid, Serial, :serial => true
  property :trasnferStatus, String
  property :from, String
  property :to, String
  property :tquantity, Integer
  property :created_by, String
  property :created_at, DateTime

  belongs_to :inv2
end

class User
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :username, String
  property :password, BCryptHash
  property :location, String

end

# Perform basic sanity checks and initialize all relationships
# Call this when you've defined all your models
DataMapper.finalize

# automatically create the post table
Inv2.auto_upgrade!
User.auto_upgrade!
Transfer.auto_upgrade!

user = User.new :name => 'chris', :password => 'password'

puts "Password stored in database: #{user.password}"

if user.password == 'password'
  puts "Logged in!"
else
  puts "Something went wrong."
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
  @inv.status = "on-hand"
  @inv.picture.sub!(/\//, '');
  if @inv.save
        {:inv => @inv, :status => "success"}.to_json
          flash[:notice] = "Record inserted correctly!"

        redirect '/'
  else
        {:inv => @inv, :status => "failure"}.to_json
  end
end

get "/newUser" do
  #@posts = Post.all()
  #Inv2.get(1).picture
  @user = User.new
  @user.name = params[:name]
  @user.username = params[:username]
  @user.password = params[:password]
  @user.location = params[:location]
  if @user.save
        {:user => @user, :status => "success"}.to_json
          flash[:notice] = "Record inserted correctly!"
          redirect '/'
  else
        {:user => @user, :status => "failure"}.to_json
  end
end

get "/newTransfer" do
  #@posts = Post.all()
  #Inv2.get(1).picture
  @user = User.new
  @user.name = params[:name]
  @user.username = params[:username]
  @user.password = params[:password]
  @user.location = params[:location]
  if @user.save
        {:user => @user, :status => "success"}.to_json
          flash[:notice] = "Record inserted correctly!"
          redirect '/'
  else
        {:user => @user, :status => "failure"}.to_json
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

#add users
get '/listUsers' do
  @user = User.all
  puts "... ... .. Password stored in database: #{user.password}"
  erb :addUser
 
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

#Add Transfer
get '/transfer' do
  @inv = Inv2.all
  erb :transfer
end

#Add User
get '/addUser' do
  erb :addUser
end

#Add User
get '/login' do
  erb :login
end

post '/delete_image' do
  @filename = params[:picture]
  FileUtils.rm_rf(Dir.glob("public/#{@filename}"))
  @files = Dir.glob("public/*.jpg")
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
  <link href="//cdn.datatables.net/plug-ins/f2c75b7247b/integration/jqueryui/dataTables.jqueryui.css" rel="stylesheet">

        
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
  <script src="https://cdn.datatables.net/1.10.5/js/jquery.dataTables.min.js"></script>
  <script src="https://cdn.datatables.net/plug-ins/f2c75b7247b/integration/bootstrap/3/dataTables.bootstrap.js"></script>
  <link href="<%= url("style.css")%>" media="all" rel="stylesheet" type="text/css" />
  
  <script type='text/javascript'>//<![CDATA[ 
    $(window).load(function(){

      document.getElementById("itemMaster").onchange = function () {
          console.log(this.options[this.selectedIndex].getAttribute("quant"));
          $('#onhandQuantity').val(this.options[this.selectedIndex].getAttribute("quant"));
      };

      // totalSummary & newQuant


      document.getElementById("toQuant").onchange = function () {
          //console.log(this.options[this.selectedIndex].getAttribute("quant"));
          //$('#totalSummary').val(this.options[this.selectedIndex].getAttribute("quant"));
          console.log("toQuant has changed!");
          var quantity = parseInt($( "#onhandQuantity" ).val()) + parseInt($( "#toQuant" ).val());
          $( "#totalSummary" ).html( "<b>Total quantiy is:</b> " + quantity );
      };

      console.log("hello");
        $('#table').dataTable({
          "paging":   true,
            "ordering": true,
            "info":     true
        });


      if (navigator.userAgent.match(/IEMobile\/10\.0/)) {
  var msViewportStyle = document.createElement('style');
  msViewportStyle.appendChild(
    document.createTextNode(
      '@-ms-viewport{width:auto!important}'
    )
  );
  document.querySelector('head').appendChild(msViewportStyle)
}     
      var isCtrl = false;$(document).keyup(function (e) {
if(e.which == 17) isCtrl=false;
}).keydown(function (e) {
    if(e.which == 17) isCtrl=true;
    if(e.which == 76 && isCtrl == true) {
        $link = $('label');
        $link[0].click()
        return false;
    // new "n"
    } else if(e.which == 78 && isCtrl == true) {
        $link = $('#newRecord');
        $link[0].click()
        return false;
        //home "h"
    } else if(e.which == 72 && isCtrl == true) {
        $link = $('#home');
        $link[0].click()
        return false;
        //upload "u"
    } else if(e.which == 85 && isCtrl == true) {
        $link = $('#upload');
        $link[0].click()
        return false;
        //help
    } else if(e.which == 13 && isCtrl == true) {
        alert('Ctrl+l: Open the left pane \n Ctrl+h: List All Records \n Ctrl+n: Add New Record \n Ctrl+u: Upload New Image \n Ctrl+Enter: Show Help \n ');
        return false;
    }
});
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
  <li class="nav-item"><a href="/" id="home"><span class="glyphicon glyphicon-home"></span>&nbsp;Home</a></li>
  <li class="nav-item"><a href="/add" id="newRecord" accesskey="a"><span class="glyphicon glyphicon-plus"></span>&nbsp;New</a></li>
  <li class="nav-item"><a href="/trasnfer" id="newRecord" accesskey="a"><span class="glyphicon glyphicon-transfer"></span>&nbsp;Trasnfers</a></li>
  <li class="nav-item"><a href="/upload" id="upload"><span class="glyphicon glyphicon-upload"></span>&nbsp;Upload</a></li>
  <li class="nav-item"><a href="/media"><span class="glyphicon glyphicon-folder-open"></span>&nbsp;Media</a></li>
  <li class="nav-item"><a href="/addUser"><span class="glyphicon glyphicon-user"></span>&nbsp;Users</a></li>
  <li class="nav-item"><a href="mailto:support@support.com"><span class="glyphicon glyphicon-question-sign"></span>&nbsp;Help</a></li>
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
                <th>Status</th>
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
                <td><%= inv[:status] %></td>

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
<form action="/new" autocomplete="off" type="post" enctype="multipart/form-data">
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
 <form action="/<%= @sinv.id %>/save" autocomplete="off" method="POST">
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
 <form action="/delete_image" method="POST">
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



@@addUser
 <div class="container">

<div class="row">
    <div class="col-xs-12 col-sm-8 col-md-6 col-sm-offset-2 col-md-offset-3">
<form action="/newUser" autocomplete="off" type="post" enctype="multipart/form-data">
   <h2>New
   <small>Add a new user</small>
    </h2>
      <hr class="colorgraph">
      <div class="row">
          <div class="form-group">
              <input type='text' class="form-control input-lg" name="name" placeholder='Name:' class="form-control input-lg"  />
          </div>
      </div>
      <div class="row">
        <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
            <input type='text' name="username" placeholder='Username:' class="form-control input-lg" />
          </div>
        </div>
        <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
            <input type='text' name="password" placeholder='Password:' class="form-control input-lg" />
          </div>
        </div>
      </div>
      
      <div class="row">
          <div class="form-group">
              <select name="location" class="form-control input-lg">
                <option value="" disabled selected>Branch</option>
                <option value="JED">JED</option>
                <option value="RYD">RYD</option>
                <option value="DMM">DMM</option>
                <option value="MAK">MAK</option>
                <option value="DAH">DAH</option>
              </select>
            </div>
        </div>
              <hr class="colorgraph">
  <div class="row">
          <div class="form-group">
        
       <input type='submit' placeholder='SUBMIT' value="Add new user" class="btn btn-primary btn-block btn-lg" />
     </div></div>
     </form>
   </div>
 </div>

 <table id="table" class="table table-striped table-bordered" cellspacing="0" width="100%">
        <thead>
            <tr>
                <th>Name</th>
                <th>Position</th>
                <th>Office</th>
                <th>Age</th>
                <th>Start date</th>
                <th>Salary</th>
            </tr>
        </thead>
 
        <tfoot>
            <tr>
                <th>Name</th>
                <th>Position</th>
                <th>Office</th>
                <th>Age</th>
                <th>Start date</th>
                <th>Salary</th>
            </tr>
        </tfoot>
 
        <tbody>
            <tr>
                <td>Tiger Nixon</td>
                <td>System Architect</td>
                <td>Edinburgh</td>
                <td>61</td>
                <td>2011/04/25</td>
                <td>$320,800</td>
            </tr>
            <tr>
                <td>Garrett Winters</td>
                <td>Accountant</td>
                <td>Tokyo</td>
                <td>63</td>
                <td>2011/07/25</td>
                <td>$170,750</td>
            </tr>
            <tr>
                <td>Ashton Cox</td>
                <td>Junior Technical Author</td>
                <td>San Francisco</td>
                <td>66</td>
                <td>2009/01/12</td>
                <td>$86,000</td>
            </tr>
            <tr>
                <td>Cedric Kelly</td>
                <td>Senior Javascript Developer</td>
                <td>Edinburgh</td>
                <td>22</td>
                <td>2012/03/29</td>
                <td>$433,060</td>
            </tr>
            <tr>
                <td>Airi Satou</td>
                <td>Accountant</td>
                <td>Tokyo</td>
                <td>33</td>
                <td>2008/11/28</td>
                <td>$162,700</td>
            </tr>
            <tr>
                <td>Brielle Williamson</td>
                <td>Integration Specialist</td>
                <td>New York</td>
                <td>61</td>
                <td>2012/12/02</td>
                <td>$372,000</td>
            </tr>
            <tr>
                <td>Herrod Chandler</td>
                <td>Sales Assistant</td>
                <td>San Francisco</td>
                <td>59</td>
                <td>2012/08/06</td>
                <td>$137,500</td>
            </tr>
            <tr>
                <td>Rhona Davidson</td>
                <td>Integration Specialist</td>
                <td>Tokyo</td>
                <td>55</td>
                <td>2010/10/14</td>
                <td>$327,900</td>
            </tr>
            <tr>
                <td>Colleen Hurst</td>
                <td>Javascript Developer</td>
                <td>San Francisco</td>
                <td>39</td>
                <td>2009/09/15</td>
                <td>$205,500</td>
            </tr>
            <tr>
                <td>Sonya Frost</td>
                <td>Software Engineer</td>
                <td>Edinburgh</td>
                <td>23</td>
                <td>2008/12/13</td>
                <td>$103,600</td>
            </tr>
            <tr>
                <td>Jena Gaines</td>
                <td>Office Manager</td>
                <td>London</td>
                <td>30</td>
                <td>2008/12/19</td>
                <td>$90,560</td>
            </tr>
            <tr>
                <td>Quinn Flynn</td>
                <td>Support Lead</td>
                <td>Edinburgh</td>
                <td>22</td>
                <td>2013/03/03</td>
                <td>$342,000</td>
            </tr>
            <tr>
                <td>Charde Marshall</td>
                <td>Regional Director</td>
                <td>San Francisco</td>
                <td>36</td>
                <td>2008/10/16</td>
                <td>$470,600</td>
            </tr>
            <tr>
                <td>Haley Kennedy</td>
                <td>Senior Marketing Designer</td>
                <td>London</td>
                <td>43</td>
                <td>2012/12/18</td>
                <td>$313,500</td>
            </tr>
            <tr>
                <td>Tatyana Fitzpatrick</td>
                <td>Regional Director</td>
                <td>London</td>
                <td>19</td>
                <td>2010/03/17</td>
                <td>$385,750</td>
            </tr>
            <tr>
                <td>Michael Silva</td>
                <td>Marketing Designer</td>
                <td>London</td>
                <td>66</td>
                <td>2012/11/27</td>
                <td>$198,500</td>
            </tr>
            <tr>
                <td>Paul Byrd</td>
                <td>Chief Financial Officer (CFO)</td>
                <td>New York</td>
                <td>64</td>
                <td>2010/06/09</td>
                <td>$725,000</td>
            </tr>
            <tr>
                <td>Gloria Little</td>
                <td>Systems Administrator</td>
                <td>New York</td>
                <td>59</td>
                <td>2009/04/10</td>
                <td>$237,500</td>
            </tr>
            <tr>
                <td>Bradley Greer</td>
                <td>Software Engineer</td>
                <td>London</td>
                <td>41</td>
                <td>2012/10/13</td>
                <td>$132,000</td>
            </tr>
            <tr>
                <td>Dai Rios</td>
                <td>Personnel Lead</td>
                <td>Edinburgh</td>
                <td>35</td>
                <td>2012/09/26</td>
                <td>$217,500</td>
            </tr>
            <tr>
                <td>Jenette Caldwell</td>
                <td>Development Lead</td>
                <td>New York</td>
                <td>30</td>
                <td>2011/09/03</td>
                <td>$345,000</td>
            </tr>
            <tr>
                <td>Yuri Berry</td>
                <td>Chief Marketing Officer (CMO)</td>
                <td>New York</td>
                <td>40</td>
                <td>2009/06/25</td>
                <td>$675,000</td>
            </tr>
            <tr>
                <td>Caesar Vance</td>
                <td>Pre-Sales Support</td>
                <td>New York</td>
                <td>21</td>
                <td>2011/12/12</td>
                <td>$106,450</td>
            </tr>
            <tr>
                <td>Doris Wilder</td>
                <td>Sales Assistant</td>
                <td>Sidney</td>
                <td>23</td>
                <td>2010/09/20</td>
                <td>$85,600</td>
            </tr>
            <tr>
                <td>Angelica Ramos</td>
                <td>Chief Executive Officer (CEO)</td>
                <td>London</td>
                <td>47</td>
                <td>2009/10/09</td>
                <td>$1,200,000</td>
            </tr>
            <tr>
                <td>Gavin Joyce</td>
                <td>Developer</td>
                <td>Edinburgh</td>
                <td>42</td>
                <td>2010/12/22</td>
                <td>$92,575</td>
            </tr>
            <tr>
                <td>Jennifer Chang</td>
                <td>Regional Director</td>
                <td>Singapore</td>
                <td>28</td>
                <td>2010/11/14</td>
                <td>$357,650</td>
            </tr>
            <tr>
                <td>Brenden Wagner</td>
                <td>Software Engineer</td>
                <td>San Francisco</td>
                <td>28</td>
                <td>2011/06/07</td>
                <td>$206,850</td>
            </tr>
            <tr>
                <td>Fiona Green</td>
                <td>Chief Operating Officer (COO)</td>
                <td>San Francisco</td>
                <td>48</td>
                <td>2010/03/11</td>
                <td>$850,000</td>
            </tr>
            <tr>
                <td>Shou Itou</td>
                <td>Regional Marketing</td>
                <td>Tokyo</td>
                <td>20</td>
                <td>2011/08/14</td>
                <td>$163,000</td>
            </tr>
            <tr>
                <td>Michelle House</td>
                <td>Integration Specialist</td>
                <td>Sidney</td>
                <td>37</td>
                <td>2011/06/02</td>
                <td>$95,400</td>
            </tr>
            <tr>
                <td>Suki Burks</td>
                <td>Developer</td>
                <td>London</td>
                <td>53</td>
                <td>2009/10/22</td>
                <td>$114,500</td>
            </tr>
            <tr>
                <td>Prescott Bartlett</td>
                <td>Technical Author</td>
                <td>London</td>
                <td>27</td>
                <td>2011/05/07</td>
                <td>$145,000</td>
            </tr>
            <tr>
                <td>Gavin Cortez</td>
                <td>Team Leader</td>
                <td>San Francisco</td>
                <td>22</td>
                <td>2008/10/26</td>
                <td>$235,500</td>
            </tr>
            <tr>
                <td>Martena Mccray</td>
                <td>Post-Sales support</td>
                <td>Edinburgh</td>
                <td>46</td>
                <td>2011/03/09</td>
                <td>$324,050</td>
            </tr>
            <tr>
                <td>Unity Butler</td>
                <td>Marketing Designer</td>
                <td>San Francisco</td>
                <td>47</td>
                <td>2009/12/09</td>
                <td>$85,675</td>
            </tr>
            <tr>
                <td>Howard Hatfield</td>
                <td>Office Manager</td>
                <td>San Francisco</td>
                <td>51</td>
                <td>2008/12/16</td>
                <td>$164,500</td>
            </tr>
            <tr>
                <td>Hope Fuentes</td>
                <td>Secretary</td>
                <td>San Francisco</td>
                <td>41</td>
                <td>2010/02/12</td>
                <td>$109,850</td>
            </tr>
            <tr>
                <td>Vivian Harrell</td>
                <td>Financial Controller</td>
                <td>San Francisco</td>
                <td>62</td>
                <td>2009/02/14</td>
                <td>$452,500</td>
            </tr>
            <tr>
                <td>Timothy Mooney</td>
                <td>Office Manager</td>
                <td>London</td>
                <td>37</td>
                <td>2008/12/11</td>
                <td>$136,200</td>
            </tr>
            <tr>
                <td>Jackson Bradshaw</td>
                <td>Director</td>
                <td>New York</td>
                <td>65</td>
                <td>2008/09/26</td>
                <td>$645,750</td>
            </tr>
            <tr>
                <td>Olivia Liang</td>
                <td>Support Engineer</td>
                <td>Singapore</td>
                <td>64</td>
                <td>2011/02/03</td>
                <td>$234,500</td>
            </tr>
            <tr>
                <td>Bruno Nash</td>
                <td>Software Engineer</td>
                <td>London</td>
                <td>38</td>
                <td>2011/05/03</td>
                <td>$163,500</td>
            </tr>
            <tr>
                <td>Sakura Yamamoto</td>
                <td>Support Engineer</td>
                <td>Tokyo</td>
                <td>37</td>
                <td>2009/08/19</td>
                <td>$139,575</td>
            </tr>
            <tr>
                <td>Thor Walton</td>
                <td>Developer</td>
                <td>New York</td>
                <td>61</td>
                <td>2013/08/11</td>
                <td>$98,540</td>
            </tr>
            <tr>
                <td>Finn Camacho</td>
                <td>Support Engineer</td>
                <td>San Francisco</td>
                <td>47</td>
                <td>2009/07/07</td>
                <td>$87,500</td>
            </tr>
            <tr>
                <td>Serge Baldwin</td>
                <td>Data Coordinator</td>
                <td>Singapore</td>
                <td>64</td>
                <td>2012/04/09</td>
                <td>$138,575</td>
            </tr>
            <tr>
                <td>Zenaida Frank</td>
                <td>Software Engineer</td>
                <td>New York</td>
                <td>63</td>
                <td>2010/01/04</td>
                <td>$125,250</td>
            </tr>
            <tr>
                <td>Zorita Serrano</td>
                <td>Software Engineer</td>
                <td>San Francisco</td>
                <td>56</td>
                <td>2012/06/01</td>
                <td>$115,000</td>
            </tr>
            <tr>
                <td>Jennifer Acosta</td>
                <td>Junior Javascript Developer</td>
                <td>Edinburgh</td>
                <td>43</td>
                <td>2013/02/01</td>
                <td>$75,650</td>
            </tr>
            <tr>
                <td>Cara Stevens</td>
                <td>Sales Assistant</td>
                <td>New York</td>
                <td>46</td>
                <td>2011/12/06</td>
                <td>$145,600</td>
            </tr>
            <tr>
                <td>Hermione Butler</td>
                <td>Regional Director</td>
                <td>London</td>
                <td>47</td>
                <td>2011/03/21</td>
                <td>$356,250</td>
            </tr>
            <tr>
                <td>Lael Greer</td>
                <td>Systems Administrator</td>
                <td>London</td>
                <td>21</td>
                <td>2009/02/27</td>
                <td>$103,500</td>
            </tr>
            <tr>
                <td>Jonas Alexander</td>
                <td>Developer</td>
                <td>San Francisco</td>
                <td>30</td>
                <td>2010/07/14</td>
                <td>$86,500</td>
            </tr>
            <tr>
                <td>Shad Decker</td>
                <td>Regional Director</td>
                <td>Edinburgh</td>
                <td>51</td>
                <td>2008/11/13</td>
                <td>$183,000</td>
            </tr>
            <tr>
                <td>Michael Bruce</td>
                <td>Javascript Developer</td>
                <td>Singapore</td>
                <td>29</td>
                <td>2011/06/27</td>
                <td>$183,000</td>
            </tr>
            <tr>
                <td>Donna Snider</td>
                <td>Customer Support</td>
                <td>New York</td>
                <td>27</td>
                <td>2011/01/25</td>
                <td>$112,000</td>
            </tr>
        </tbody>
    </table>


@@login
<div class="container">
<div class="row">
    <div class="col-xs-12 col-sm-8 col-md-6 col-sm-offset-2 col-md-offset-3">
<form action="/new" autocomplete="off" type="post" enctype="multipart/form-data">
   <h2>New
   <small>Login Form</small>
    </h2>
      <hr class="colorgraph">
      <div class="row">
        <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
            <input type='text' name="name" placeholder='Username:' class="form-control input-lg" />
          </div>
        </div>
        <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
            <input type='text' name="name" placeholder='Password:' class="form-control input-lg" />
          </div>
        </div>
      </div>
              <hr class="colorgraph">
  <div class="row">
          <div class="form-group">
        
       <input type='submit' placeholder='SUBMIT' value="Submit" class="btn btn-primary btn-block btn-lg" />
     </div></div>
     </form>
   </div>
 </div>


@@transfer
<div class="container">

<div class="row">
    <div class="col-xs-12 col-sm-8 col-md-6 col-sm-offset-2 col-md-offset-3">
 <form action="/save" autocomplete="off" method="POST">
   <h2>Edit
   <small>an existing stock item</small>
 </h2>
      <hr class="colorgraph">
      <div class="row">
        <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
        <input name="_method" type="hidden" value="PUT" />
         <select id="itemMaster" name="itemMaster" class="form-control input-lg">
        <% @inv.each_with_index do |inv1, index| %>
          <option quant="<%= inv1[:quantity] %>" value="<%= inv1[:id] %>"><%= inv1[:code] %>  + <%= inv1[:location] %></option>
          <%= inv1[:code] %>
        </option>
        <% end %>
      </select>
        </div>
        </div>
        <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
       <input type='text' id="onhandQuantity" name="name" class="form-control input-lg" disabled placeholder='Quantity:' value='<%= @inv[1][:quantity] %>' />
          </div>
        </div>
      

        <!-- <%= @inv[2][:name] %> -->

        
 <div class="row">
 <div class="col-xs-6 col-sm-6 col-md-6">
 To:

          <div class="form-group">
             <select id="itemMaster" name="itemMaster" class="form-control input-lg">
                <% @inv.each_with_index do |inv1, index| %>
                  <option quant="<%= inv1[:quantity] %>" value="<%= inv1[:id] %>"><%= inv1[:code] %>  + <%= inv1[:location] %></option>
                  <%= inv1[:code] %>
                </option>
                <% end %>
              </select>
          </div>
          <div class="col-xs-6 col-sm-6 col-md-6">
            <div class="form-group">
                  <input type='text' id="onhandQuantity" name="name" class="form-control input-lg" disabled placeholder='Quantity:' value='<%= @inv[1][:quantity] %>' />
            </div>
        </div>
</div>

      </div>
              </div>
       <div class="row">
        <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
              <input type='number' size='10' id='toQuant' pattern="\d+" min="0" step="1" name='toQuant' value='0' class="form-control input-lg" />
              <span id="totalSummary">Hello</span>
          </div>
        </div>
      </div>
       <div class="row">

        <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
                    <input type='submit' placeholder='Save Changes'  value="Save Changes" class="btn btn-primary btn-block btn-lg" />
          </div>
      </div>
    </div>

     </form>
</div>
</div>
</div>
