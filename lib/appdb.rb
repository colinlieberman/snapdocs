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
            'host', host,
            'port', port,
            'database', name,
            'username', ruser['user'],
            'password', ruser['pass']
        ]

        #$error_logger.puts opts.inspect

        @rh = Mysql2::Client.new( opts )
        
        opts['username'] = wuser['user']
        opts['password'] = wuser['pass']
        #$error_logger.puts opts.inspect
        
        @wh = Mysql2::Client.new( opts )

    end

    def saved?( item_md5 )
        stmt = @rh.prepare( 'SELECT COUNT(*) FROM saved WHERE id = ?' )
        r = stmt.execute( item_md5 )

        return r.first == 1
    end

    def self_finalize( obj )
        @rh.close
        @wh.close
    end
end
