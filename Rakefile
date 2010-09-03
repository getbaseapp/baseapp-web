require 'app'
require 'sinatra/activerecord/rake'

require 'heroku'

desc 'cron'
task :cron do
  `heroku pgdumps:capture`
end
