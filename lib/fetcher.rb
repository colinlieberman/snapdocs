require 'uri'
require 'open-uri'
require 'rss'
require 'digest'
require 'appdb'

class Fetcher
    # fetches and parses rss feeds
   
    attr_accessor :url
    attr_reader :error
    attr_reader :okay
    attr_reader :headlines

    def initialize( url )

        @url   = ''
        @error = ''
        @okay  = true
        
        @channel   = ''
        @headlines = []

        # validate feed url
        # this is a little hacky - uri.parse is pretty generous, I'd like
        # to use scheme limiting, but that's only available in the extract method; 
        # so we'll do that, expecting an array of one item
        urls = URI.extract( url, ['http', 'https'] )

        if urls.length != 1
            @okay = false
            @error = "Couldn't parse #{url}"
            return
        end

        @url = urls[0]

    end

    def fetch()
        if !@okay or @url == ''
            @okay = false
            return false
        end
  
        # unset any existing headlines
        @headlines = []

        open( @url ) do |rss|
            begin
                feed = RSS::Parser.parse(rss)
            rescue Exception => e
                @okay  = false
                @error = 'RSS parsing error: ' + e.message
                return false
            end
           
            # get db to check if link is saved and include
            # that in response
            db = AppDB.instance
               
            # TODO: make use of this in ouput
            @channel = feed.channel.title

            feed.items.each do |item|
                # use link md5 as key
                md5 = Digest::MD5.hexdigest( item.link );
                is_saved = db.saved?( md5 )
                
                @headlines.push Hash[ 'title' => item.title, 'link' => item.link, 
                                       'md5' => md5, 'saved' => is_saved ]
            end
        end

        if @headlines.size == 0
            @okay = false
            @error = "Nothing found for feed"
            return false
        end

        return true
    end
end
