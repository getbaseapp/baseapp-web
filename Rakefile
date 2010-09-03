require 'app'
require 'sinatra/activerecord/rake'

require 'heroku'

task :cron do
  `heroku pgdumps:capture`
end
