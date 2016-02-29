require 'rubygems'
require 'sinatra'
require 'logger'
require 'fetcher'
require 'saver'
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

    post '/f/save' do
        error = false
        
        [ 'id', 'link', 'title' ].each { |arg|
            if !params.has_key?( arg ) || !params[arg]
                # yes, this is error message would only give one of multiple missing params
                error = "param #{arg} missing or empty" 
            end
        } 

        if error
            status 400
            body error
            return
        end

        saver = Saver.new();

        if saver.save( params['id'], params['title'], params['link'] )
            status 200
            body JSON.dump( Hash[ 'saved', params['id'] ] )
            return
        else
            status 400
            body saver.error
        end
    end
end
