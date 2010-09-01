require 'sinatra/base'
require 'warden-googleapps'

enable :sessions

use Warden::Manager do |manager|
  manager.default_strategies :google_apps
  manager.failure_app = BadAuthentication
  manager[:google_apps_domain] = 'getbaseapp.com'
end

helpers do
  def ensure_authenticated
    unless ENV['RACK_ENV'] == 'development' || env['warden'].authenticate!
      throw(:warden)
    end
  end
end

class BadAuthentication < Sinatra::Base
  get '/unauthenticated' do
    status 403
    erb "<h3>Unable to authenticate, sorry dude.</h3>"
  end
end
