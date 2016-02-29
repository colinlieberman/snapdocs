var App = {
    'sources': {
        'nyt':    'http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml'
        ,'hn':     'https://news.ycombinator.com/rss'
        ,'reddit': 'https://www.reddit.com/.rss'
        ,'bbc':    'http://feeds.bbci.co.uk/news/rss.xml'
        ,'slash':  'http://rss.slashdot.org/Slashdot/slashdotMain'
    }
}; 

$( 'docuemnt' ).ready(function() {
    /* initialized tabs */
    $( 'div#tabs' ).tabs();
    
    /* initialize lookup form */
    initLookup();

    /* initialize source buttons */
    initSources();
});

function initSave() {
    $( 'div#result a.save' ).click(function(e){
        e.preventDefault();
        var that  = $(this);
        var li    = that.closest( 'li' );
        var id    = li.attr( 'id' );
        var url   = that.attr( 'href' );
        var link  = that.next( 'a.link' );
        var lurl  = link.attr( 'href' );
        var title = link.text();
    
        doXHR( url, {id: id, link: lurl, title: title}, function(data, text_status, jqxhr){
            /* on success, get the img html, remove the save anchor, and prepend the img */
            var img_html = that.html();
            that.remove();
            li.prepend( img_html );
        });
    } );
}

function doXHR( url, data, success_callback, before_send ) {
    $.ajax({ 
        url:    url
        ,method: 'POST'
        ,data:   data
        
        ,beforeSend: function() {
            if( typeof before_send === 'function' ) {
                before_send();
            }
            
            $( 'p#error' ).hide();
            $( '*' ).css( 'cursor', 'wait' );
        }    
        
        ,success: success_callback
        
        ,error: function( jqxhr, text_status, error_thrown ) {
            var http_status   = jqxhr.status;
            var response_text = jqxhr.responseText;
            
            var error_text = text_status + ': ' + this.url +
                '<br />' + http_status + ' ' + error_thrown;
            
            /* don't throw walls of html into errors */
            if( response_text.length < 128 ) {
                error_text += '<br />' + response_text;
            }

            displayError( error_text );
        }

        ,complete: function() {
            $( '*' ).css( 'cursor', '' );
        }
    });
}

function displayError( error_text ) {
    $( 'p#error' ).html( error_text ).show();
}

function initLookup() {
    var form = $( 'form#feed' );
    form.submit(function(e){
        e.preventDefault();

        var url = $( 'input#domain' ).val();
        doXHR( '/f/fetcher', { 'url': url }, function( data, text_status, jqxhr ) {
                var data;
                try {
                    data = JSON.parse( data );
                    // console.log( data ); 
                }
                catch(e) {
                    displayError( "I don't know what to do with " + data
                        + "<br />" + e.message ); 
                }
               
                /* reset result to empty list */
                var result_div = $( '#result' );
                result_div.html( '<ul></ul>' );
                var result_list = result_div.find( 'ul' ).first();

                for( var i in data ) {
                    var item = data[i];
                    
                    if( typeof item.link === 'undefined' 
                    || typeof item.title === 'undefined' 
                    || typeof item.md5 === 'undefined' ) {
                        displayError( "response in unexpected format" );
                        return;
                    }
                    
                    var title = item.title;
                    var link  = item.link;
                    var md5   = item.md5; 
                    var saved = item.saved;

                    if( !title || !link || !md5 ) {
                        continue;
                    }

                    /* "save_html" is the img whether the link is saved
                     * if it's not, wrap it with an anchor
                     */
                    var save_html = '<img class="save" src="/img/db.png" width="21"'
                        + ' height="24" title="save link" alt="save link" />'

                    if( !saved ) {
                        save_html = '<a class="save" href="/f/save">' + save_html + '</a>';
                    }
                    
                    result_list.append( '<li id="' + md5 +'"> ' + save_html + '<a class="link" href="' 
                        + link + '" target="_blank">' + title + '</a></li>');
                }


                /* initialize save buttons */
                initSave();
                result_div.show();
            }
            ,function() {
                $( 'div#result' ).hide();
           });
    });
}

function initSources() {
    $( '#right li' ).click(function() {
        var id = $(this).attr( 'id' );
    
        if( typeof App.sources[ id ] === 'undefined' ) {
            alert( "Error: I don't know what to do for " + id );
            return false;
        }

        var feed_url = App.sources[ id ];
        $( 'input#domain' ).val( feed_url );
    });
}
