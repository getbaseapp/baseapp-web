require 'app'
require 'sinatra/activerecord/rake'

require 'heroku'

desc 'Backup database'
task(:backup_database) { backup_database }

desc 'cron'
task :cron => :backup_database

def backup_database
  client = Heroku::Client.new ENV['BACKUP_USER'], ENV['BACKUP_PASSWORD']
  client.post '/apps/baseapp/pgdumps', :accept => :json
end
