require 'rubygems'
require 'rack'
require 'tilt'
require 'rack-protection'
require 'sinatra'

set :port, 8080
set :bind, 'www.cactusflower.org'

get '/' do
  'Hello world!'
end
