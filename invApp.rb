require "rubygems"
require "sinatra"
require 'sinatra/flash'
require "data_mapper"
require 'json'
require 'find'
require 'chartkick'
include Chartkick::Helper
require 'groupdate'


require 'fileutils'
include FileUtils::Verbose


#require "sinatra-authentication"

require "dm-core"
#for using auto_migrate!
require "dm-migrations"
require "digest/sha1"
#require 'rack-flash'
  
use Rack::Session::Cookie, :secret => 'Y0ur s3cret se$$ion key'

Chartkick.options = {
  colors: ["#63b598", "#ce7d78", "#ea9e70", "#a48a9e", "#c6e1e8"]
}


set :bind, '0.0.0.0'

=begin

use Rack::Auth::Basic, "Restricted Area" do |username, password|
    [username, password] == ['admin', 'admin']  
end

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['admin', 'admin']
  end
end

puts @username

oldverb = $VERBOSE; $VERBOSE = nil
require 'iconv'
$VERBOSE = oldverb

use Rack::MethodOverride
set :method_override, true

configure do
  enable :method_override
end

enable :sessions

=end

# If you want the logs displayed you have to do this before the call to setup
DataMapper::Logger.new($stdout, :debug)

# need install dm-sqlite-adapter
DataMapper::setup(:default, ENV['HEROKU_POSTGRESQL_GOLD_URL']) # || "sqlite3://#{Dir.pwd}/data1.dat")
enable :sessions

error 400..510 do
  'http error...'
end

helpers do
  def logged_in?
    (@auth_email && !@auth_email.empty?) ? true : false
  end
end

def require_logged_in
  redirect('/login') unless is_authenticated?
end
 
def is_authenticated?
  return !!session[:user_id]
end

def require_admin
  redirect('/') unless is_admin?
end

def is_admin?
  if session[:isAdmin] == "admin"
    return true
  else
    return false
  end
end

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
  property :created_by, String
  property :created_at, DateTime

  has n, :transfer
end

class Transfer
  include DataMapper::Resource
  property :tid, Serial, :serial => true
  property :transferName, String
  property :transferDesc, String
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
  property :isAdmin, Boolean, :default  => false
  property :isActive, Boolean, :default  => true

end

# Perform basic sanity checks and initialize all relationships
# Call this when you've defined all your models
DataMapper.finalize

# automatically create the post table
Inv2.auto_upgrade!
#User.auto_upgrade!
Transfer.auto_upgrade!

User.auto_upgrade!
#clear all data
#DataMapper.auto_migrate!

#DataMapper.auto_upgrade!


configure do
  set :sinatra_authentication_view_path, Pathname(__FILE__).dirname.expand_path + "views/"
end

use Rack::Session::Cookie, :secret => "heyhihello"


#user = User.new :name => 'chris', :password => 'password'

#puts "Password stored in database: #{user.password}"

#if user.password == 'password'
#  puts "Logged in!"
#else
#  puts "Something went wrong."
#end

get "/new" do
  require_logged_in
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
  @inv.status = "ONHD"
  @inv.picture.sub!(/\//, '');
  @inv.created_by = session[:user_id]
  @inv.created_at = Time.now
  if @inv.save
        #{:inv => @inv, :status => "success"}.to_json
        flash[:notice] = "Record inserted correctly!"
        redirect '/'
  else
        {:inv => @inv, :status => "failure"}.to_json
  end
end

get "/dashboard" do
  require_logged_in
  require_admin
  @inv = Inv2.all
  #@inv.to_array
  #render json: Inv2.group_by_day(:created_at).count
  erb :dashboard
end

get "/dashboard5" do
  #@inv.to_array
  #render json: Inv2.group_by_day(:created_at).count
  erb :dashboard5
end

get "/dashboard3" do
  @inv = Inv2.all
  #@inv.to_array
  #render json: Inv2.group_by_day(:created_at).count
  erb :dashboard3
end


get "/dashboard4" do
  @inv = Inv2.all
  #@inv.to_array
  #render json: Inv2.group_by_day(:created_at).count
  erb :dashboard4
end

get '/dashboard2' do
@graph_data = [["A", 1000], ["B", 2000], ["C", 7000]]
    erb :dashboard2
end

get "/newUser" do
  require_logged_in
  #@posts = Post.all()
  #Inv2.get(1).picture
  @user = User.new
  @user.name = params[:name]
  @user.username = params[:username]
  @user.password = params[:password]
  @user.location = params[:location]
  @user.isAdmin = params[:isAdmin].nil? ? false : true
  @user.isActive = params[:isActive].nil? ? false : true
  if @user.save
        {:user => @user, :status => "success"}.to_json
          flash[:notice] = "Record inserted correctly!"
          redirect '/'
  else
        {:user => @user, :status => "failure"}.to_json
  end
end


post "/login" do
  @user = User.first(:name => params[:username])
  if @user != nil
    if @user.password == params[:password] and @user.isActive
        session[:user_id] = @user.name
        session[:branch_code] = @user.location
        session[:isAdmin] = @user.isAdmin ? "admin" : "access"
        flash[:notice] = "Howdy " + session[:user_id] + "! Logged in correctly! " #+ session[:isAdmin] 
        redirect '/'
    else
          flash[:notice] = "Username or password is incorrect!"
          redirect '/login'
    end
  else
    flash[:notice] = "Username or password is incorrect. Please try again!"
    redirect '/login'
  end
end

get "/logout" do
  require_logged_in
  session[:user_id] = nil
  session[:branch] = nil
  session[:isAdmin] = nil
  flash[:success] = "You logged out from the system. You have to enter your username and password to log in back to the system."
  redirect '/login'
end

get "/newTransfer" do
  require_logged_in
  @inv = Inv2.all
  flash[:notice] = "Logged in at #{Time.now}."
  erb :newTransfer
end

put "/newTransfer" do
  require_logged_in
  #@posts = Post.all()
  #Inv2.get(1).picture
  # t = Transfer.new("en-route","JED","RYD",44,"Saleh")
  flash[:notice] = "Logged in at #{Time.now}."

  @t = Transfer.new
  @t.trasnferStatus = "PCKDUP"
  @t.transferName = params[:transferName]
  @t.transferDesc = params[:transferDesc]
  @t.from = params[:fromItem]
  @t.to = params[:toItem]
  @t.tquantity = params[:toQuant]
  @t.created_by = session[:user_id] # static value now! params[:created_by]
  @t.created_at = Time.now
  @t.inv2 = Inv2.get(1)
  
  if params[:fromItem] == params[:toItem]
    @t = Transfer.all
    flash[:error] = "From and To are the same, please choose another"
    redirect back
  end

  if @t.save
          #{:t => @t, :status => "success"}.to_json
          flash[:success] = "Record inserted correctly! Please insert another one or return to the homepage."
          redirect "/newTransfer"
  else
        {:t => @t, :status => "failure"}.to_json
  end
end

get "/transfer" do
  require_logged_in
  #@posts = Post.all()
  #Inv2.get(1).picture
  @t = Transfer.all
  flash[:notice] = "Logged in at #{Time.now}."
  erb :transfer
end

#delete Transfer
get "/:tid/deleteTrans" do
  require_logged_in
    @t = Transfer.first(:tid => params[:tid])
    @inv = Inv2.first(:code=>@t.from)
    @inv.quantity = @inv.quantity + @t.tquantity
    @inv.save
    if @t.destroy
        {:t => @t, :status => "success"}.to_json
        flash[:notice] = "The record was deleted.."
        redirect '/transfer'
    else
        {:t => @t, :status => "failure"}.to_json
    end
end


#delete User
get "/:id/deleteUser" do
  require_logged_in
    @t = User.first(:id => params[:id])
    if @t.destroy
        {:t => @t, :status => "success"}.to_json
        flash[:notice] = "The user record was deleted.."
        redirect '/listUsers'
    else
        {:t => @t, :status => "failure"}.to_json
    end
end


#find and Edit Transfer
get "/:tid/editTrans" do
  require_logged_in
    #@inv = Inv2.find(params[:id])
    @t = Transfer.first(:tid => params[:tid])
    # If statement to change the inventory trasnfer status
    # 1) PCKDUP => Decreases the quantity in the "FROM" location
    # 2) ENRT
    # 3) RCVD
    # 4) ONHD => Increases the stock quantity in the "TO" location & Transferred record will be flagged as "archived" 
    # Deleting the transfer before "ONHD" will return the original quantity to the original number
    @t.created_by = session[:user_id]
    @t.created_at = Time.now
    if @t.trasnferStatus == "PCKDUP"
      puts "value validated!"
      @t.trasnferStatus = "ENRT"
      @inv = Inv2.first(:code=>@t.from)
      puts @inv
      @inv.quantity = @inv.quantity - @t.tquantity
      @inv.save
    elsif @t.trasnferStatus == "ENRT"
      puts "value validated!"
      @t.trasnferStatus = "RCVD"
    elsif @t.trasnferStatus == "RCVD"
      puts "value validated!"
      @t.trasnferStatus = "ONHD"
      @inv = Inv2.first(:code=>@t.to)
      puts @inv
      @inv.quantity = @inv.quantity + @t.tquantity
      @inv.save
    end

    if @t.save
        #{:t => @t, :status => "success"}.to_json
        flash[:notice] = "Saved correctly!"
        redirect '/transfer'
    else
          {:inv => @inv, :status => "failure"}.to_json
    end
end

#update	
put "/:id/save" do
  require_logged_in
  @inv = Inv2.first(:id => params[:id])
  @inv.code = params[:code]
  @inv.name = params[:name]
  @inv.size = params[:size]
  @inv.quantity = params[:quantity]
  @inv.type = params[:type]
  @inv.location = params[:location]
  @inv.picture = params[:picture]
  @inv.created_by = session[:user_id]
  @inv.created_at = Time.now
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


#update User
put "/:id/saveUser" do
  require_logged_in
  @user = User.first(:id => params[:id])
  @user.name = params[:name]
  @user.username = params[:username]
  @tempPass = @user.password
  if @tempPass !=  params[:orPass]
    @user.password = params[:password]
  end
  @user.location = params[:location]
  @user.isAdmin = params[:isAdmin].nil? ? false : true
  @user.isActive = params[:isActive].nil? ? false : true
  #@inv.created_by = session[:user_id]
  #@inv.created_at = Time.now
  if @user.save
        flash[:notice] = "Saved correctly!"
        redirect '/listUsers'
  else
        {:inv => @inv, :status => "failure"}.to_json
  end
end

#delete
get "/:id/delete" do
  require_logged_in
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
  require_logged_in
    #@inv = Inv2.find(params[:id])
    @inv = Inv2.all
    @sinv = Inv2.first(:id => params[:id])
    @files = Dir.glob("public/*.jpg")
    #@inv.to_json
    erb :edit
end

#Edit User
get "/:id/editUser" do
  require_logged_in
  require_admin
  #@inv = Inv2.find(params[:id])
  @user = User.first(:id => params[:id])
  erb :editUser
end

get "/" do
  require_logged_in
  #protected!
  #@posts = Post.all()  #Inv2.get(1).picture
  @inv = Inv2.all
  @files = Dir.glob("public/*.jpg")
  flash[:notice] = "<b>Howdy " + (session[:user_id] || "") + "!</b> You logged in at #{Time.now}."
  erb :default
end

get "/sessions1" do
  session[:user_id] = "saleh" #params["user_id"]
  session[:branch_code] = "RYD"
  redirect('/')
end

get "/login" do
  #require_logged_in
  #protected!
  #@posts = Post.all()
  #Inv2.get(1).picture
  erb :login
end

get "/add" do
  require_logged_in
  @inv = Inv2.all
  @files = Dir.glob("public/*.jpg")
  erb :add
end


get "/upload" do
  require_logged_in
  @inv = Inv2.all
  erb :upload
end
 
post '/save_image' do
  require_logged_in
  @inv = Inv2.all
  @filename = params[:file][:filename]
  file = params[:file][:tempfile]
 
  File.open("public/#{@filename}", 'wb') do |f|
    f.write(file.read)
  end
  
  erb :show_image
end

get '/list' do
  require_logged_in
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
  require_logged_in
  @user = User.all
  erb :listUsers
 
end


get '/media' do
  require_logged_in
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
  require_logged_in
  @inv = Inv2.all
  erb :transfer
end

#Add User
get '/addUser' do
  require_logged_in
  require_admin
  erb :addUser
end

#Add User
get '/login' do
  require_logged_in
  erb :login
end

post '/delete_image' do
  require_logged_in
  @filename = params[:picture]
  FileUtils.rm_rf(Dir.glob("public/#{@filename}"))
  @files = Dir.glob("public/*.jpg")
  erb :media
end

# get all images
get '/debug/posts/images/' do
  require_logged_in
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
  <link href="<%= url("bootstrap.min.css") %>" media="all" rel="stylesheet" type="text/css">
  <link href="//cdn.datatables.net/plug-ins/f2c75b7247b/integration/jqueryui/dataTables.jqueryui.css" rel="stylesheet">

        
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
  <script src="https://cdn.datatables.net/1.10.5/js/jquery.dataTables.min.js"></script>
  <script src="https://cdn.datatables.net/plug-ins/f2c75b7247b/integration/bootstrap/3/dataTables.bootstrap.js"></script>
  <link href="<%= url("style.css")%>" media="all" rel="stylesheet" type="text/css" />
  <script src="//www.google.com/jsapi"></script>
  <script src=<%= url("chartkick.js")%>></script>
  <script src=<%= url("tableToExcel.js")%>></script>


  
  <script type='text/javascript'>//<![CDATA[ 
    $(window).load(function(){

      $('.header').click(function(){
      $(this).nextUntil('tr.header').slideToggle(1);
      });

      var toItem = document.getElementById("toItem");
        if(toItem != null) {
          toItem.onchange = function () {
          console.log(this.options[this.selectedIndex].getAttribute("quant"));
          $('#toQuantity').val(this.options[this.selectedIndex].getAttribute("quant"));


          //console.log(this.options[this.selectedIndex].getAttribute("quant"));
          //$('#totalSummary').val(this.options[this.selectedIndex].getAttribute("quant"));
          console.log("toQuant has changed!");

          //var quantity = parseInt($( "#onhandQuantity" ).val()) + parseInt($( "#toQuant" ).val());
          //fromItem
          var fromQuantity = parseInt($( "#fromQuantity" ).val()) - parseInt($( "#toQuant" ).val());
          var toQuantity = parseInt($( "#toQuantity" ).val()) + parseInt($( "#toQuant" ).val());
          
          //$( "#totalSummary" ).html( "<b>Total quantiy in " + + " is:</b> " + quantity );
          $( "#totalSummary" ).html( "<center>Total quantiy in " + $( "#fromItem" ).text() + " is: <h1>" + fromQuantity + "</h1><br> Total quantiy in " + $( "#toItem" ).text() + " is:</b><h1> " + toQuantity + "</h1></center>" );
        }
      };

      var fromItem = document.getElementById("fromItem");
      if(fromItem != null) {
      fromItem.onchange = function () {
          console.log(this.options[this.selectedIndex].getAttribute("quant"));
          $('#fromQuantity').val(this.options[this.selectedIndex].getAttribute("quant"));

          //console.log(this.options[this.selectedIndex].getAttribute("quant"));
          //$('#totalSummary').val(this.options[this.selectedIndex].getAttribute("quant"));
          console.log("toQuant has changed!");

          //var quantity = parseInt($( "#onhandQuantity" ).val()) + parseInt($( "#toQuant" ).val());
          //fromItem
          var fromQuantity = parseInt($( "#fromQuantity" ).val()) - parseInt($( "#toQuant" ).val());
          var toQuantity = parseInt($( "#toQuantity" ).val()) + parseInt($( "#toQuant" ).val());
          
          //$( "#totalSummary" ).html( "<b>Total quantiy in " + + " is:</b> " + quantity );
          $( "#totalSummary" ).html( "<center>Total quantiy in " + $( "#fromItem" ).text() + " is: <h1>" + fromQuantity + "</h1><br> Total quantiy in " + $( "#toItem" ).text() + " is:</b><h1>" + toQuantity + "</h1></center>");
        }
      };

      // totalSummary & newQuant

      var toQuant = document.getElementById("toQuant");
      if(toQuant != null) {
      toQuant.onchange = function () {
          //console.log(this.options[this.selectedIndex].getAttribute("quant"));
          //$('#totalSummary').val(this.options[this.selectedIndex].getAttribute("quant"));
          console.log("toQuant has changed!");

          //var quantity = parseInt($( "#onhandQuantity" ).val()) + parseInt($( "#toQuant" ).val());
          //fromItem
          var fromQuantity = parseInt($( "#fromQuantity" ).val()) - parseInt($( "#toQuant" ).val());
          var toQuantity = parseInt($( "#toQuantity" ).val()) + parseInt($( "#toQuant" ).val());
          
          //$( "#totalSummary" ).html( "<b>Total quantiy in " + + " is:</b> " + quantity );
          $( "#totalSummary" ).html( "<center>Total quantiy in " + $( "#fromItem" ).text() + " is:<h1>" + fromQuantity + "<br></h1>Total quantiy in " + $( "#toItem" ).text() + " is:</b> <h1>" + toQuantity + "</h1></center>");
        }
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
        //Just make sure not to screw things up with no image is selected
        if (imgs != null) {
          var element = document.getElementById("picture");
          alert("Picture is: " + $("img.hover").attr('src') );
          element.value = $("img.hover").attr('src');
        }
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

  <% if session[:user_id] != nil %>
<ul class="navigation">
  <li class="nav-item"><a href="/" id="home"><span class="glyphicon glyphicon-home"></span>&nbsp;Home</a></li>
  <li class="nav-item"><a href="/add" id="newRecord" accesskey="a"><span class="glyphicon glyphicon-plus"></span>&nbsp;New</a></li>
  <li class="nav-item"><a href="/transfer" id="newRecord" accesskey="a"><span class="glyphicon glyphicon-transfer"></span>&nbsp;Trasnfers</a></li>
  <li class="nav-item"><a href="/upload" id="upload"><span class="glyphicon glyphicon-upload"></span>&nbsp;Upload</a></li>
  <li class="nav-item"><a href="/media"><span class="glyphicon glyphicon-folder-open"></span>&nbsp;Media</a></li>
  <% if is_admin? %>
  <li class="nav-item"><a href="/dashboard"><span class="glyphicon glyphicon-dashboard"></span>&nbsp;Dashboard</a></li>
    <li class="nav-item"><a href="/listUsers"><span class="glyphicon glyphicon-user"></span>&nbsp;Users</a></li>

  <% end %>
  <li class="nav-item"><a href="mailto:support@support.com"><span class="glyphicon glyphicon-question-sign"></span>&nbsp;Help</a></li>
  <li class="nav-item"><a href="/logout"><span class="glyphicon glyphicon-log-out"></span>&nbsp;Log out</a></li>
</ul>

<input type="checkbox" id="nav-trigger" class="nav-trigger" />
<label for="nav-trigger"></label>
<% end %>
<div class="site-wrap">
      <% if flash[:notice] %>
        <p class="alert alert-info"><%= flash[:notice] %></p>
      <% end %>
      <% if flash[:success] %>
        <p class="alert alert-success"><%= flash[:success] %></p>
      <% end %>
      <% if flash[:error] %>
         <p class="alert alert-danger"><%= flash[:error] %></p>
       <% end %>

      <%= yield %>
</div>

</body>
</html>

@@default
<hr class="colorgraph">
 <h1>Inventory Management v1</h1>
 <h3>Simple stock management solution</h3>
 <!--
 <input type="button" onclick="tableToExcel('testTable', 'W3C Example Table')" value="Export to Excel">
 -->
<div class="table-responsive">
  <a href="/add">Add a new Item Master</a>
      <table id="testTable" class="responsive-table responsive-table-input-matrix">
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

@@listUsers
<hr class="colorgraph">
 <h1>Inventory Management v1</h1>
 <h3>List Users</h3>
<div class="table-responsive">
  <a href="/addUser">Add a new User</a>
      <table id="testTable" class="responsive-table responsive-table-input-matrix">
        <thead>
            <tr>
                <th>Row</th>
                <th>Name</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
          <% @user.each_with_index do |user, index| %>
            <tr>
                <td><%= index += 1 %></td>
                <td><%= user[:name] %></td>
                <td><a id="editLink" onclick="console.log('clicked!!!');" href="/<%= user[:id] %>/editUser">Edit</a> | <a href="/<%= user[:id] %>/deleteUser" onclick="return confirm('are you sure?')">Delete</a></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
</div>

@@transfer
<hr class="colorgraph">
 <h1>Inventory Management v1</h1>
 <h3>Simple stock management solution</h3>
<div class="table-responsive">
      <a href="/newTransfer">Add New Stock Transfer</a>
      <table class="responsive-table responsive-table-input-matrix">
        <thead>
            <tr>
                <th>Row</th>
                <th>From</th>
                <th>To</th>
                <th>Quantity</th>
                <th>Transfer Status</th>
                <th>Created By</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>

          <% temp = "newtest" %>
          <% puts temp %>
          <% @t.each_with_index do |tt, index| %>
            <% if temp != tt[:transferName] %>
            <% temp = tt[:transferName] %>            
            <tr  class="header">
              <td colspan="7"><%= tt[:transferName] %> | <%= tt[:transferDesc] %></td>
            </tr>
            <% end%>
            <tr>
                <td><%= index += 1 %></td>
                <td><%= tt[:from] %></td>
                <td><%= tt[:to] %></td>
                <td><%= tt[:tquantity] %></td>
                <td><%= tt[:trasnferStatus] %></td>
                <td><%= tt[:created_by] %></td>

                <td><a id="editLink" onclick="console.log('clicked!!!');" href="/<%= tt[:tid] %>/editTrans">Change Status</a> | <a href="/<%= tt[:tid] %>/deleteTrans" onclick="return confirm('are you sure?')">Delete</a></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
</div>



@@add
 <div class="container">

<div class="row">
    <div class="col-xs-12">
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
    <div class="col-xs-12">
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
        <input type="hidden" name="picture" id="picture" value="/<%= @sinv.picture %>">
        <input type='submit' placeholder='Save Changes' value="Save Changes" class="btn btn-primary btn-block btn-lg" />
     </form>
</div>
</div>
</div>

@@upload
 <div class="container">
  <div class="row">
    <div class="col-xs-12">
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
    <div class="col-xs-12">
      <h1>Uploaded Image</h1>
      <img src="./<%= @filename %>" />
    </div>
  </div>
</div>

@@media
<div class="container">

<div class="row">
    <div class="col-xs-12">
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
    <div class="col-xs-12">
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

      <div class="row">
          <div class="form-group">
                    <input type='checkbox' name='isActive' value='true' checked />Active
                    <input type='checkbox' name='isAdmin' value='true' />Admin
            </div>
      </div>

        <hr class="colorgraph">
        <div class="row">
          <div class="form-group">
            <input type='submit' placeholder='SUBMIT' value="Add new user" class="btn btn-primary btn-block btn-lg" />
          </div>
        </div>
     </form>
   </div>
 </div>



@@editUser
 <div class="container">

<div class="row">
    <div class="col-xs-12">
<form action="/<%= @user.id %>/saveUser" autocomplete="off" method="post" enctype="multipart/form-data">
   <h2>Edit
   <small>Edit user</small>
    </h2>
      <hr class="colorgraph">
      <div class="row">
          <div class="form-group">
              <input name="_method" type="hidden" value="PUT" />
              <input type='text' class="form-control input-lg" name="name" placeholder='Name:' class="form-control input-lg" value='<%= @user.name %>'  />
          </div>
      </div>
      <div class="row">
        <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
            <input type='text' name="username" placeholder='Username:' class="form-control input-lg" value='<%= @user.username %>' />
          </div>
        </div>
        <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
            <input type='text' name="password" placeholder='Password:' class="form-control input-lg" value='<%= @user.password %>' />
            <input type="hidden" name="orPass" id="orPass" value='<%= @user.password %>'>
          </div>
        </div>
      </div>
      
      <div class="row">
          <div class="form-group">
              <select name="location" class="form-control input-lg">
                <% ["JED", "RYD", "DMM", "MAK", "DAH"].each do |selectInvValue| %>
                <option <%= 'selected="selected"' if selectInvValue == @user.location %> value="<%= selectInvValue %>"><%= selectInvValue %></option>
              <% end %>
              </select>
            </div>
      </div>

      <div class="row">
          <div class="form-group">
                    <input type='checkbox' name='isActive' value='true' <% if @user.isActive %> checked <% end %> />Active
                    <input type='checkbox' name='isAdmin' value='true' <% if @user.isAdmin %> checked <% end %>  />Admin
            </div>
      </div>

        <hr class="colorgraph">
        <div class="row">
          <div class="form-group">
            <input type='submit' placeholder='SUBMIT' value="Save Changes" class="btn btn-primary btn-block btn-lg" />
          </div>
        </div>
     </form>
   </div>
 </div>


@@login
<div class="container">
<div class="row">
    <div class="col-xs-12">
<form action="/login" autocomplete="off" method="post" enctype="multipart/form-data">
   <h2>Login:
   <small>Please enter your username and password</small>
    </h2>
      <hr class="colorgraph">
      <div class="row">
        <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
            <input type='text' id="username" name="username" placeholder='Username:' class="form-control input-lg" />
          </div>
        </div>
        </div>
        <div class="row">
        <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
            <input type='password' id="password" name="password" placeholder='Password:' class="form-control input-lg" />
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


@@newTransfer
<div class="container">

<div class="row">
    <div class="col-xs-12">
   <form action="/newTransfer" autocomplete="off" method="POST">
   <h2>Edit
    <small>an existing stock item</small>
   </h2>
   <hr class="colorgraph">
        <input name="_method" type="hidden" value="PUT" />
        <div class="row">
          <div class="col-xs-6 col-sm-6 col-md-6">
            <div class="form-group">
              <input type='text' id="transferName" name="transferName" placeholder='Transfer Name:' class="form-control input-lg" />
            </div>
          </div>
          <div class="col-xs-6 col-sm-6 col-md-6">
            <div class="form-group">
              <input type='text' id="transferDesc" name="transferDesc" placeholder="Description" class="form-control input-lg" />
            </div>
          </div>
        </div>

      <div class="row">
        <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
         <select id="fromItem" name="fromItem" class="form-control input-lg">
          <option value="" disabled selected>From</option>
          <% @inv.each_with_index do |inv1, index| %>
            <option quant="<%= inv1[:quantity] %>" value="<%= inv1[:code] %>"><%= inv1[:code] %>  in <%= inv1[:location] %></option>
              <%= inv1[:code] %>
            </option>
          <% end %>
        </select>
        </div>
        </div>
        <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
            <input type='text' id="fromQuantity" name="name" class="form-control input-lg" disabled placeholder='Quantity:' />
          </div>
        </div>
      </div>



 
       <div class="row">
              <div class="col-xs-6 col-sm-6 col-md-6">
                <div class="form-group">
                   <select id="toItem" name="toItem" class="form-control input-lg">
                    <option value="" disabled selected>To</option>
                      <% @inv.each_with_index do |inv1, index| %>
                        <option quant="<%= inv1[:quantity] %>" value="<%= inv1[:code] %>"><%= inv1[:code] %>  in <%= inv1[:location] %></option>
                        <%= inv1[:code] %>
                      </option>
                      <% end %>
                    </select>
                </div>
              </div>
                <div class="col-xs-6 col-sm-6 col-md-6">
                  <div class="form-group">
                        <input type='text' id="toQuantity" name="name" class="form-control input-lg" disabled placeholder='Quantity:' />
                  </div>
              </div>
        </div>


       <div class="row">
        <div class="col-xs-6 col-sm-6 col-md-6">
          <div class="form-group">
              <input type='number' size='10' id='toQuant' pattern="\d+" min="0" step="1" name='toQuant' value='0' class="form-control input-lg" />
          </div>
        </div>
      </div>

      <div class="row">
        <span id="totalSummary"></span><br>
        <div class="form-group">
          <input type='submit' placeholder='Save Changes'  value="Save Changes" class="btn btn-primary btn-block btn-lg" />
        </div>
      </div>

     </form>

</div>
</div>

@@dashboard

<div class="container">
    <div class="heading">
         <div class="col"></div>
        <div class="col"></div>
    </div>
 <div class="table-row">
         <div class="col"><%= pie_chart Inv2.aggregate(:location, :quantity.sum) %>
                         <p>Number of stock per location</p>
</div>
      <div class="col">      <%= pie_chart Inv2.aggregate(:type, :quantity.sum) %>
                        <p>Number of stock per Item Type</p>

      </div>
    </div>
 <div class="table-row">
         <div class="col"><%= pie_chart Inv2.aggregate(:size, :quantity.sum) %>
                          <p>Number of stock per Item Size</p>

</div>
      <div class="col">
        <%= column_chart Inv2.aggregate(:location, :quantity.sum), stacked:true %>
                <p>Number of stock per location</p>

      </div>
    </div>
</div>


@@dashboard3
<%= pie_chart Inv2.all(:location => "RYD").map{|inv| [inv.code, inv.quantity] } %>


@@dashboard5
<%= pie_chart Inv2.aggregate(:location, :quantity.sum) %>

@@dashboard4
<%= line_chart Inv2.aggregate(:created_at, :all.count) %>

@@dashboard2

<%= pie_chart @graph_data %>