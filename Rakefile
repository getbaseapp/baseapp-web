require 'app'
require 'sinatra/activerecord/rake'

require 'heroku'

task :cron
  client = Heroku::Client.new ENV['BACKUP_USER'], ENV['BACKUP_PASSWORD']
  client.post '/apps/baseapp/pgdumps', :accept => :json
end
