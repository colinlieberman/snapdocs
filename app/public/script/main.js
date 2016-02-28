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

function displayError( error_text ) {
    $( 'p#result' ).hide();
    $( 'p#error' ).html( error_text ).show();
}

function initLookup() {
    var form = $( 'form#feed' );
    form.submit(function(e){
        e.preventDefault();

        var url = $( 'input#domain' ).val();
        $.ajax
        ({ 
            url:    '/f/fetcher'
           ,method: 'POST'
           ,data:   { 'url': url }
            
           ,beforeSend: function() {
                $( 'p#error' ).hide();
                $( 'div#result' ).hide();
                $( '*' ).css( 'cursor', 'wait' );
            }    
           
           ,success: function( data, text_status, jqxhr ) {
                var data;
                try {
                    data = JSON.parse( data );
                    console.log( data );
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

                    if( !title || !link || !md5 ) {
                        continue;
                    }

                    var save_html = '<a class="save" href="/f/save"><img class="save" src="/img/db.png" width="21"'
                        + ' height="24" title="save link" alt="save link" /></a>'
                    
                    result_list.append( '<li id="' + md5 +'"> ' + save_html + '<a class="link" href="' 
                        + link + '" target="_blank">' + title + '</a></li>');
                }
                result_div.show();
            }
            
           ,error: function( jqxhr, text_status, error_thrown ) {
                var http_status   = jqxhr.status;
                var response_text = jqxhr.responseText;
                
                var error_text = text_status + ': ' + this.url +
                    '<br />' + http_status + ' ' + error_thrown +
                    '<br />' + response_text;
                
                displayError( error_text );
            }

           ,complete: function() {
                $( '*' ).css( 'cursor', '' );
           }
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
