require 'app'
require 'sinatra/activerecord/rake'

require 'heroku'
require 'tasks/rake_helper'

task :cron => :environment do
  client = Heroku::Client.new ENV['BACKUP_USER'], ENV['BACKUP_PASSWORD']
  client.post '/apps/baseapp/pgdumps', :accept => :json
end
