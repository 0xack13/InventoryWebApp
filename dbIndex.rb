require 'sinatra'

get '/' do
  erb :home
end

get '/about' do
  erb :about
end

get '/contact' do
  erb :contact
end

__END__
@@layout
<% title="Songs By Sinatra" %>
<!doctype html>

<html class=''>
<head><meta charset='UTF-8'><meta name="robots" content="noindex">
  <link href="<%= url("style.css")%>" media="all" rel="stylesheet" type="text/css" />
  
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap-theme.min.css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
  <style type="text/css">
      .bs-example{
        margin: 20px;
      }
  </style>
</head>
<body>
<div id='container'>
  <div class='signup'>
     <form>
       <input type='text' placeholder='Item #:'  />
       <input type='text' placeholder='Name:'  />
       <input type='text' placeholder='Warehouse:'  />
       <input type='text' placeholder='Quantity:'  />
       <input type='submit' placeholder='SUBMIT' />
     </form>
  </div>
  <div class='whysign'>
    <h1>Inventory Management</h1>
    <p>Basic stock information</p>
      <table class="table table-striped">
        <thead>
            <tr>
                <th>Row</th>
                <th>Item #</th>
                <th>Name</th>
                <th>Warehouse</th>
                <th>Quantity</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>3</td>
                <td>213444</td>
                <td>Caps Green</td>
                <td>JED-WH</td>
                <td>14</td>
            </tr>
            <tr>
                <td>3</td>
                <td>213444</td>
                <td>Caps Green</td>
                <td>JED-WH</td>
                <td>14</td>
            </tr>
            <tr>
                <td>3</td>
                <td>213444</td>
                <td>Caps Green</td>
                <td>JED-WH</td>
                <td>14</td>
            </tr>
            <tr>
                <td>3</td>
                <td>213444</td>
                <td>Caps Green</td>
                <td>JED-WH</td>
                <td>14</td>
            </tr>
            <tr>
                <td>3</td>
                <td>213444</td>
                <td>Caps Green</td>
                <td>JED-WH</td>
                <td>14</td>
            </tr>
            <tr>
                <td>3</td>
                <td>213444</td>
                <td>Caps Green</td>
                <td>JED-WH</td>
                <td>14</td>
            </tr>
            <tr>
                <td>3</td>
                <td>213444</td>
                <td>Caps Green</td>
                <td>JED-WH</td>
                <td>14</td>
            </tr>
            <tr>
                <td>3</td>
                <td>213444</td>
                <td>Caps Green</td>
                <td>JED-WH</td>
                <td>14</td>
            </tr>
            <tr>
                <td>3</td>
                <td>213444</td>
                <td>Caps Green</td>
                <td>JED-WH</td>
                <td>14</td>
            </tr>
        </tbody>
      </table>
    <p>Learn: 
      <span>In</span>
      <span>Out</span>
      <span>All</span>
    </p>
  </div>
</div>


</body></html>

@@home
<p>Welcome to this website that's all about the songs of the great
  Frank Sinatra.</p>

@@about
<p>This site is a demonstration of how to build a website using 
  Sinatra.</p>

@@contact
<p>You can contact me by sending an email to daz at gmail.com</p>
