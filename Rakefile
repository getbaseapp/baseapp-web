require 'app'
require 'rake'
require 'sinatra/activerecord/rake'

task :cron => :environment do
 if Time.now.hour == 0
   `heorku pgdumps:capture`
 end
end
