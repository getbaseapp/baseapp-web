require 'app'
require 'rake'
require 'sinatra/activerecord/rake'

task :cron do
 if Time.now.hour == 0
   `heroku pgdumps:capture`
 end
end
