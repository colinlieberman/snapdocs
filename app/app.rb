require 'rubygems'
require 'sinatra'
require 'logger'
require 'fetcher'
require 'json'

class SnapdocsExercise < Sinatra::Base

    access_logger = Logger.new( "#{ENV['APPROOT']}/log/app.log" )
    
    $error_logger = File.new( "#{ENV['APPROOT']}/log/app.err", 'a+' )
    $error_logger.sync = true

    configure do
        disable :show_exceptions
        use ::Rack::CommonLogger, access_logger
    end

    before {
        env[ 'rack.errors' ] = $error_logger
    }

    get '/' do
        erb :index
    end

    post '/f/fetcher' do
        if !params.has_key?( 'url' )
            status 400
            body "target url not found in request"
            return
        end
 
        fetcher = Fetcher.new( params['url'] )

        if !fetcher.okay or ! fetcher.fetch()
            status 400
            body fetcher.error
            return
        end
  
        body JSON.dump( fetcher.headlines )
    end
end
