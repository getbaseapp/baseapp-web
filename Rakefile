require 'app'
require 'rake'
require 'sinatra/activerecord/rake'

task :cron do
  `heroku pgdumps:capture`
end
