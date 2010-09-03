require 'app'
require 'sinatra/activerecord/rake'

require 'heroku'

desc 'cron'
task :cron do
  `pg_dump`
end
