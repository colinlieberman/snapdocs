require 'appdb'

class Saver
    attr_reader :error

    def save( id, title, link )
        db = AppDB.instance
        
        #save returns saved id or error
        result = db.save( id, title, link )
        
        if result == id 
            return true
        else
            @error = result
            return false
        end
    end
end
