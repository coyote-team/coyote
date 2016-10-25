(function(){
  var coyote = {};
  var CoyoteBookmarklet = {
    visible : true,
    consumer : {
      css : ['/assets/coyote_bookmarklet.css'], // could be an array or a string
      init: function(){
        //console.log('consumer init');
        //send images to producer
        var $images = $('img');
        var imgs  = [];
        var pageIdCounter = 0;
        var domain = document.domain;
        $images.each(function(){
          $(this).data('coyote-page-id', pageIdCounter);
          pageIdCounter += 1;
          imgs.push( {
            "coyote-page-id": pageIdCounter,
            "src": $(this)[0].src,
            "alt": $(this).attr('alt')
          });
        });
        //console.log("token");
        //console.log(token);
        coyote_consumer.producer.populateImages(coyote_token, domain, imgs);
      },
      methods : { // The methods that the producer can call
        annotateImages: function(imgs){
          //console.log('annotateImages');
        }
      }
    },

    producer : {
      path : "/coyote_producer", // The path on your app that provides your data service
      init: function() {
        //console.log('producer init');
        coyote.getWebsites = function(){
          var getWebsites = $.ajax({
            url: 'websites',
            method: "GET",
            dataType: "json",
            headers: coyote.headers
          });
          getWebsites.done(function( data ) {
            //console.log(data);
            //create if doesn't exist
            var websites = jsonQ(data);
            var website = websites.find('url', function () {
              return this[0].indexOf(coyote.domain) !== -1;
            });
            console.log(website);
            if(website.length > 0){
              coyote.website = website;
              coyote.getImages();
            } else {
              coyote.postWebsite();
            }
          });
          getWebsites.fail(function(jqXHR, textStatus) {
            console.log( "getWebsites failed: " + textStatus );
          });
        };
        coyote.postWebsite = function(){
          var data = {
           "url" : coyote.domain,
           "title" : coyote.domain
          };
          var postWebsite = $.ajax({
            url: 'websites',
            data: data,
            method: "POST",
            dataType: "json",
            headers: coyote.headers
          });
          postWebsite.done(function( data ) {
            console.log(data);
          });
          postWebsite.fail(function(jqXHR, textStatus) {
            console.log( "postWebsites failed: " + textStatus );
          });
        };
        coyote.getImages = function(){
          var getImages = $.ajax({
            url: 'images',
            method: "GET",
            dataType: "json",
            headers: coyote.headers
          });
          getImages.done(function( data ) {
            var site_images = [];
            var coyote_images = jsonQ(data);
            var coyote_matches = coyote_images.find('path', function () {
              //TODO
              //return this[0].indexOf(coyote.domain) !== -1;
              return false;
            });
            if(coyote_matches.length == site_images.length){
              //TODO
              coyote.addLinks();
            } else {
              //for each
              //post image
            }
          });
          getImages.fail(function(jqXHR, textStatus) {
            console.log( "getImages failed: " + textStatus );
          });
        };
        coyote.postImage = function(){
          coyote.addLinks();
        };
        //TODO later
        //coyote.postDescription = function(){
        //};
        coyote.addLinks = function(){
          //var link = "/images/new";
          //var $item = $('<div class="item"><a target="_blank" href="' + link + '">Describe</a></div>');
          coyote_producer.consumer.annotateImages();
        }
      },
      methods : { // The methods that the consumer can call
        populateImages: function(token, domain, imgs) {
          coyote.token = token;
          coyote.headers = { 'X-Auth-Token' : coyote.token };
          console.log('populating imgs');
          coyote.imgs = imgs;
          coyote.domain = domain;

          var $coyoteItems = $('#coyote-items');
          $.each(imgs, function() {
            var $img = $('<img/>', {
              'id': "coyote-" + this["coyote-page-id"],
              'src': this["src"],
              'alt': this["alt"]
            });
            var $item = $('<div class="item"></div>');
            $img.prependTo($item);
            $coyoteItems.append($item);
          });
          coyote.getWebsites();
          //TODO insert descriptions
          return false;

        },
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

