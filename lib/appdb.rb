require 'singleton'
require 'yaml'
require 'mysql2'

class AppDB
    include Singleton

    def initialize
        conf_path = "#{ENV['APPROOT']}/conf/config.yaml"

        # let default exceptions kill the app dead if the file
        # isn't readable or the config is wong

        conf_file = File.open( conf_path )

        conf = YAML.load( conf_file.read )

        conf_file.close

        dbconf = conf['db']

        #$error_logger.puts dbconf.inspect
    
        host = dbconf['host']
        port = dbconf['port']
        name = dbconf['name']

        ruser = dbconf['read']
        wuser = dbconf['write']

        opts = Hash[
            'host' => host,
            'port' => port,
            'database' => name,
            'username' => ruser['user'],
            'password' => ruser['pass']
        ]

        #$error_logger.puts opts.inspect

        @rh = Mysql2::Client.new( opts )
        
        opts['username'] = wuser['user']
        opts['password'] = wuser['pass']
        #$error_logger.puts opts.inspect
        
        @wh = Mysql2::Client.new( opts )

    end

    def getSaved()
        stmt = @rh.prepare( 'SELECT id, title, link, saved_on FROM saved ORDER BY saved_on DESC' )
        r = stmt.execute()

        # massage from object to array so callers don't care
        results = []
        r.each do |row|
            results.push( Hash[
                'id'        => row['id'],
                'title'     => row['title'],
                'link'      => row['link'],
                'saved_on'  => Time.at( row['saved_on'] ).strftime( '%a %d %b %Y at %H:%M' )
            ] )
        end

       $error_logger.puts results.inspect

        return results
    end

    def saved?( item_md5 )
        stmt = @rh.prepare( 'SELECT COUNT(*) AS n FROM saved WHERE id = ?' )
        r = stmt.execute( item_md5 )
        return r.first['n'] == 1
    end

    def save( item_md5, title, link )
        # let duplicate id throw error; treat that as an application issue
        # because we shouldn't allow the request in the first place
        stmt = @wh.prepare( 'INSERT INTO saved (id, title, link) VALUES (?, ?, ?)' )
        
        begin
            r = stmt.execute( item_md5, title, link )

        rescue Mysql2::Error => e
            return "Error saving link"
        end
            
        return item_md5

    end

    def self_finalize( obj )
        @rh.close
        @wh.close
    end
end
