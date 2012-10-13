require 'sinatra/base'
require 'coffee-script'
require 'sinatra/assetpack'
require 'rufus/scheduler'
require 'json'
require './apartments'
require './loader'

scheduler = Rufus::Scheduler.start_new

scheduler.every '2h' do
  Loader.run
end

class App < Sinatra::Base
  register Sinatra::AssetPack

  assets do
    js :app, [
      'js/app/app.js',
      'js/app/apartment.js',
      'js/vendor/handlebars-1.0.0.beta.6.js'
    ]
    css :application, [
      'css/application.css'
    ]
  end

  get '/' do
    erb :index
  end

  get '/apartments' do
    Apartments.all.to_json
  end
end
