require 'app'
require 'sinatra/activerecord/rake'

require 'heroku'

task :cron do
  client = Heroku::Client.new 'hd13b1sh99u', 'max@bylinebreak.com'
  client.post '/apps/baseapp/pgdumps', :accept => :json
end
