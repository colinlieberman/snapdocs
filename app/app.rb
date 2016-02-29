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


    get '/f/saved' do
        saver = Saver.new()
        saved = saver.getSaved()
        
        saved_heading = "Saved Articles"

        if saved.length == 0
            saved_heading = "No Saved Articles"
        end
    
        body JSON.dump( Hash[ 'title' => saved_heading, 'saved' => saved ] )
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


    
    post '/f/unsave' do
        if !params.has_key?( 'id' )
            status 400
            body "target id not found in request"
            return
        end

        saver = Saver.new()
  
        if saver.unsave( params['id'] )
            status 200
            body JSON.dump( Hash[ 'unsaved' => params['id'] ] )
            return
        else
            status 400
            body saver.error
        end
    end


    post '/f/save' do
        error = false
        
        [ 'id', 'link', 'title' ].each do |arg|
            if !params.has_key?( arg ) || !params[arg]
                # yes, this is error message would only give one of multiple missing params
                error = "param #{arg} missing or empty" 
            end
        end

        if error
            status 400
            body error
            return
        end

        saver = Saver.new();

        if saver.save( params['id'], params['title'], params['link'] )
            status 200
            body JSON.dump( Hash[ 'saved' => params['id'] ] )
            return
        else
            status 400
            body saver.error
        end
    end


end
