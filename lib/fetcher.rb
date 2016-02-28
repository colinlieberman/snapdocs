require 'uri'
require 'open-uri'
require 'rss'
require 'digest'

class Fetcher
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

        # this is a little hacky - uri.parse is pretty generous, scheme limiting 
        # is only in the extract method; so we'll do that, expecting an array
        # of one item
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

        begin
            open( @url ) do |rss|
                feed = RSS::Parser.parse(rss)
                
                @channel = feed.channel.title

                feed.items.each do |item|
                    # use link md5 as key
                    md5 = Digest::MD5.hexdigest( item.link );
                    
                    @headlines.push Hash[ 'title', item.title, 'link', item.link, 'md5', md5 ]
                end
            end
        
        rescue Exception => e
            @okay  = false
            @error = e.message
            return false
        end

        if @headlines.size == 0
            @okay = false
            @error = "Nothing found for feed"
            return false
        end

        return true
    end
end