(function(){
  var CoyoteBookmarklet = {
    visible : true,

    consumer : {
      css : ['/assets/coyote_bookmarklet.css'], // could be an array or a string
      init: function(){
        console.log('consumer init');
        //send images to producer
        var $images = $('img');
        var imgs  = [];
        var pageIdCounter = 0;
        $images.each(function(){
          $(this).data('coyote-page-id', pageIdCounter);
          pageIdCounter += 1;
          imgs.push( { 
            "src": $(this)[0].src,
            "alt": $(this).attr('alt')
          });
        });
        coyote_consumer.producer.populateImages(imgs);
      },
      methods : { // The methods that the producer can call
        annotateImages: function(imgs){
          console.log('annotateImages');
          console.log(imgs);
        }
      }
    },

    producer : {
      path : "/coyote_producer", // The path on your app that provides your data service
      methods : { // The methods that the consumer can call
        populateImages: function(imgs){
          var $coyoteItems = $('#coyote-items');
          $.each(imgs, function() {
            var link = "/images/new";
            var $img = $('<img/>', {
              'src': this["src"],
              'alt': this["alt"]
            });

            //TODO get request for website
            var request = $.ajax({
              url: apiRoot() + "websites",
              method: "GET",
              dataType: "JSON"
            });
            request.done(function( data ) {
              console.log(data);
              //create if doesn't exist
                //TODO post request for website
              //TODO get request for image
              //TODO insert descriptions
              //TODO post request for image
              //TODO create link for description
            });
            request.fail(function( jqXHR, textStatus ) {
              console.log( "Request failed: " + textStatus );
            });
            var $item = $('<div class="item"><a target="_blank" href="' + link+'">Describe</a></div>');
            $img.prependTo($item);
            //$coyoteItems.append(link  );
            $coyoteItems.append($item);
                  
          });
          return false;
        },
        apiRoot: function() {
          return '/api/v1/';
        } 
        // The RPC method used by our consumer.
        //fvbPost : function(vote,url,callback){
          // Since this code will be executed inside of our producer page
          // and not on the client, we can make use of JQuery
          //$.post( '/pages', { page : { url : url, vote : vote } }, callback, 'json')
        //}
      }
    }
  }
  
  window.CoyoteBookmarklet = CoyoteBookmarklet;

})();

