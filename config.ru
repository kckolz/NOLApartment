require 'sinatra'
 
set :environment, :production
disable :run

require File.join(File.dirname(__FILE__), 'main')
run Sinatra::Application
