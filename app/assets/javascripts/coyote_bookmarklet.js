(function(){
  var coyote = {};
  var CoyoteBookmarklet = {
    visible : true,
    consumer : {
      css : ['/assets/coyote_bookmarklet.css'], 
      init: function(){
        //console.log('consumer init');
        //send images to producer
        var $images = $('img');
        var imgs  = [];
        var pageIdCounter = 0;
        var domain = document.domain;
        var protocol = document.location.protocol;
        $images.each(function(){
          //mark them with an arbitrary counter so we can find them later for annotations
          $(this).data('coyote-page-id', pageIdCounter);
          pageIdCounter += 1;
          imgs.push( {
            "coyote-page-id": pageIdCounter,
            "src": $(this)[0].src,
            "alt": $(this).attr('alt')
          });
        });
        //coyote_token comes from body of bookmarklet coyote_consumer/index.js.erb
        coyote_consumer.producer.populateImages(coyote_token, domain, protocol,  imgs);
      },
      methods : { 
        annotateImages: function(imgs){
          console.log('annotateImages');
        }
      }
    },

    producer : {
      path : "/coyote_producer", // The path on your app that provides your data service
      init: function() {
        //console.log('producer init');
        
        coyote.getWebsites = function(){
          //console.log('getWebsites');
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
            console.log(coyote.full_domain);
            var website = websites.find('url', function () {
              return this[0].indexOf(coyote.full_domain) !== -1;
            });
            if(website.length > 0){
              console.log(website);
              coyote.website_id = website.id;
              coyote.showButtons();
            } else {
              coyote.postWebsite();
            }
          });
          getWebsites.fail(function(jqXHR, textStatus) {
            console.log( "getWebsites failed: " + textStatus );
          });
        };

        coyote.postWebsite = function(){
          //console.log('postWebsites');
          var data = {
           "website" :{
             "url" : coyote.full_domain,
             "title" : coyote.full_domain
           }
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
            //TODO check if id
            //else show errors
            coyote.website_id = data.id;
            coyote.showButtons();
          });
          postWebsite.fail(function(jqXHR, textStatus) {
            console.log( "postWebsites failed: " + textStatus );
          });
        };

        coyote.showButtons = function(){
          var $items = $('#coyote-items .item');
          $items.each(function() {
            var $btn = $('<button class="btn btn-primary">Describe</button>')
            var $img = $(this).find('img');
            var imgObj = {
              "css_id": $img.attr('id'),
              "src": $img[0].src,
              "alt": $img.attr('alt')
            };
            $btn.click(function(){
              $(this).parents('.item').fadeOut();
              coyote.getImages(function(data){
                var src = imgObj.src;
                //var path = imgObj.src.replace(/^(https?:|)\/\//, '//')
                var imgs = jsonQ(data);
                var img = imgs.find('path', function () {
                  return this[0].indexOf(src) !== -1;
                });
                if(img.length > 0){
                  //TODO check page urls
                  console.log(img);
                  window.open("/descriptions/new?image_id="+img.id);
                } else {
                  coyote.postImage(imgObj);
                }
              });
            });
            $(this).append($btn);
          });
        }

        coyote.postImage = function(imgObj){
          console.log('postImage');
          var canonical_id = "bookmarklet_" + coyote.website_id + "_" + imgObj.css_id + "_"+ Date.now();
          //TODO add page urls
          //TODO path logic...
          //var path = imgObj.src.replace(/^(https?:|)\/\//, '//')
          //console.log(path);
          var data = {
           "image" :{
             "path" : imgObj.src,
             "title": imgObj.alt,
             "website_id" : coyote.website_id,
             "group_id" : "1",
             "canonical_id" : canonical_id
           }
          };
          var postImage = $.ajax({
            url: 'images',
            data: data,
            method: "POST",
            dataType: "json",
            headers: coyote.headers
          });
          postImage.done(function( data ) {
            console.log(data);
            //TODO check if id
            window.open("/descriptions/new?image_id="+data.id);
            //else show errors
          });
          postImage.fail(function(jqXHR, textStatus) {
            console.log( "postImage failed: " + textStatus );
          });
        };

        //TODO later for showing annotations
        coyote.getImages = function(callback){
          //console.log('getImages');
          var data = { "website_id": coyote.website_id};
          var getImages = $.ajax({
            url: 'images',
            method: "GET",
            data: data, 
            dataType: "json",
            headers: coyote.headers
          });
          getImages.done(function( data ) {
            callback(data);
            //var srcs = coyote.imgs.map(function(img){
              //return img["src"];
            //});
            //var coyote_images = jsonQ(data);
            //var coyote_matches = coyote_images.find('path', function () {
              //srcs.indexOf(this[0]) !== -1;
              ////TODO
              ////return this[0].indexOf(coyote.domain) !== -1;
              //return false;
            //});
            //if(coyote_matches.length == site_images.length){
              ////TODO
              ////coyote_producer.consumer.annotateImages();
            //} else {
              ////for each
              ////post image
            //}
          });
          getImages.fail(function(jqXHR, textStatus) {
            console.log( "getImages failed: " + textStatus );
          });
        };
        //TODO later
        //coyote.postDescription = function(){
        //};
      },
      methods : { // The methods that the consumer can call
        populateImages: function(token, domain, protocol, imgs) {
          coyote.token = token;
          coyote.headers = { 
            'X-Auth-Token' : coyote.token,
            'Accept': 'application/json'
          };
          console.log('populating imgs');
          coyote.imgs = imgs;
          coyote.domain = domain;
          coyote.protocol = protocol;
          coyote.full_domain = coyote.protocol + "//" + coyote.domain;

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

