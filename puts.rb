#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'

get '/' do
  <<-eos
<html>
  <body>
    <form action="/putsomething" method="post">
      <input type="hidden" name="_method" value="put" />
      <input type="submit">
    </form>
  </body>
</html>
eos
end

put '/putsomething' do
  "You put something!"
end
