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

    per_beds = @apartments.select { |a| a['price'] && a['beds'] }
      .map { |a| a['price'].to_i / a['beds'].to_i }

    @avg_per_bed = per_beds.inject(:+) / per_beds.length

    erb :index
  end

  get '/apartments' do
    Apartments.all.to_json
  end
end
