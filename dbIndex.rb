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
<% title="Inventory Management" %>
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
  <div class='signup form-group'>
     <form>
       <input type='text' placeholder='Code:'  />
       <input type='text' placeholder='Name:'  />
       <select class="form-control">
        <option value="" disabled selected>Size</option>
        <option value="A3">A3</option>
        <option value="A4">A4</option>
        <option value="XL">XL</option>
        <option value="XXL">XXL</option>
      </select>
       <input type='text' placeholder='Quantity:'  />
       <select class="form-control">
        <option value="" disabled selected>Type</option>
        <option value="Catalogue">Catalogue</option>
        <option value="Flyer">Flyer</option>
        <option value="Sticker">Sticker</option>
        <option value="Poster">Poster</option>
        <option value="Folder">Folder</option>
      </select>
      <select class="form-control">
        <option value="" disabled selected>Location</option>
        <option value="Catalogue">Catalogue</option>
        <option value="Flyer">Flyer</option>
        <option value="Sticker">Sticker</option>
        <option value="Poster">Poster</option>
        <option value="Folder">Folder</option>
      </select>
       <input type="file" name="picture" class="form-control">
       <input type='submit' placeholder='SUBMIT' />
     </form>
  </div>
  <div class='whysign'>
    <h1>Inventory Management</h1>
    <p>Stock Summary</p>
      <table class="table table-striped">
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
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>1</td>
                <td>213444</td>
                <td>Caps Green</td>
                <td>JED-WH</td>
                <td>14</td>
                <td>14</td>
                <td>JED-WH</td>
                <td>14</td>
            </tr>
            <tr>
                <td>2</td>
                <td>213444</td>
                <td>Caps Green</td>
                <td>JED-WH</td>
                <td>14</td>
                <td>14</td>
                <td>JED-WH</td>
                <td>14</td>
            </tr>
            <tr>
                <td>3</td>
                <td>213444</td>
                <td>Caps Green</td>
                <td>JED-WH</td>
                <td>14</td>
                <td>14</td>
                <td>JED-WH</td>
                <td>14</td>
            </tr>
            <tr>
                <td>4</td>
                <td>213444</td>
                <td>Caps Green</td>
                <td>JED-WH</td>
                <td>14</td>
                <td>14</td>
                <td>JED-WH</td>
                <td>14</td>
            </tr>
            <tr>
                <td>5</td>
                <td>213444</td>
                <td>Caps Green</td>
                <td>JED-WH</td>
                <td>14</td>
                <td>14</td>
                <td>JED-WH</td>
                <td>14</td>
            </tr>
            <tr>
                <td>6</td>
                <td>213444</td>
                <td>Caps Green</td>
                <td>JED-WH</td>
                <td>14</td>
                <td>14</td>
                <td>JED-WH</td>
                <td>14</td>
            </tr>
            <tr>
                <td>7</td>
                <td>213444</td>
                <td>Caps Green</td>
                <td>JED-WH</td>
                <td>14</td>
                <td>14</td>
                <td>JED-WH</td>
                <td>14</td>
            </tr>
            <tr>
                <td>8</td>
                <td>213444</td>
                <td>Caps Green</td>
                <td>JED-WH</td>
                <td>14</td>
                <td>14</td>
                <td>JED-WH</td>
                <td>14</td>
            </tr>
            <tr>
                <td>9</td>
                <td>213444</td>
                <td>Caps Green</td>
                <td>JED-WH</td>
                <td>14</td>
                <td>14</td>
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
