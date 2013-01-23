require 'sinatra/base'
require 'rufus/scheduler'
require 'json'
require './apartments'
require './loader'

scheduler = Rufus::Scheduler.start_new

scheduler.every '2h' do
  Loader.run
end

scheduler.cron '0 3 * * *' do
  Loader.expire
end

class App < Sinatra::Base
  get '/' do
    @apartments = Apartments.all
    erb :index
  end

  get '/apartments' do
    Apartments.all.to_json
  end
end
