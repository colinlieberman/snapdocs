require 'rubygems'
require 'sinatra'

class SnapdocsExercise < Sinatra::Base

    get '/' do
        erb :index
    end
end
