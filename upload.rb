require 'fileutils'
require 'sinatra'

include FileUtils::Verbose

get '/upload' do
    erb :upload
end

post '/upload' do
    tempfile = params[:file][:tempfile] 
    filename = params[:file][:filename] 
    cp(tempfile.path, "uploads/#{filename}")
    'Yeaaup'
end

__END__

@@upload
<form action='/upload' enctype="multipart/form-data" method='POST'>
    <input name="file" type="file" />
    <input type="button" value="Upload" />
</form>