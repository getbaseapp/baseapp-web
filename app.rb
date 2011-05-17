require 'rubygems'
require 'sinatra'

require 'yaml'

get '/?' do
  response.headers['Cache-Control'] = 'public, max-age=31557600'

  haml :home, :locals => { :body_id => "home" }
end

get '/mas/?' do
  response.headers['Cache-Control'] = 'public, max-age=31557600'

  redirect 'http://itunes.apple.com/us/app/baseapp/id437385415?mt=12&ls=1'
end

get '/download/?' do
  response.headers['Cache-Control'] = 'public, max-age=31557600'

  redirect 'http://baseapp.s3.amazonaws.com/BaseApp1.0.6.zip'
end

get '/faq/?' do
  response.headers['Cache-Control'] = 'public, max-age=31557600'

  haml :faq, :locals => { :body_id => "support" }
end
