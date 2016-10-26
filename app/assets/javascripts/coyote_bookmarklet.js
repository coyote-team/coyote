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
        var href = document.location.href;
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
        coyote_consumer.producer.populateImages(domain, protocol, href,  imgs);
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
            //TODO is user logged in?
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
            var $btn = $('<button class="btn btn-info">Describe</button>')
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
                  //TODO add page url to image record if not present
                  window.open("/descriptions/new?image_id="+img.id+"&metum_id=1");
                } else {
                  coyote.postImage(imgObj);
                }
              });
            });
            $(this).append($btn);
            //annotate images
            coyote.getImages();
          });
        }

        coyote.postImage = function(imgObj){
          console.log('postImage');
          var canonical_id = "bookmarklet_" + coyote.website_id + "_" + imgObj.css_id + "_"+ Date.now();
          //TODO protocol match logic...
          //var path = imgObj.src.replace(/^(https?:|)\/\//, '//')
          //console.log(path);
          var data = {
           "image" :{
             "path" : imgObj.src,
             "title": imgObj.alt,
             "website_id" : coyote.website_id,
             "group_id" : "1",
             "canonical_id" : canonical_id,
             "page_urls": { coyote.href }
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
            var srcs = coyote.imgs.map(function(img){
              return img["src"];
            });
            var coyote_images = jsonQ(data);
            var coyote_matches = coyote_images.find('path', function () {
              return srcs.indexOf(this[0]) !== -1;
            });
            $.each(coyote_matches, function() {
              console.log(coyote_matches);
              //TODO replace alts
              //TODO show widget
            });
          });
          getImages.fail(function(jqXHR, textStatus) {
            console.log( "getImages failed: " + textStatus );
          });
        };
        coyote.getDescription = function(){
        };
        //TODO later
        //coyote.postDescription = function(){
        //};
      },
      methods : { // The methods that the consumer can call
        populateImages: function(domain, protocol, href, imgs) {
          console.log('populating imgs');
          //set shared vars onto coyote object for ajax calls
          coyote.headers = { 
            'Accept': 'application/json'
          };
          coyote.imgs = imgs;
          coyote.domain = domain;
          coyote.protocol = protocol;
          coyote.href = href;
          coyote.full_domain = coyote.protocol + "//" + coyote.domain;

          //add imgs to grid
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
          return false;
        },
      }
    }
  }
  window.CoyoteBookmarklet = CoyoteBookmarklet;
})();

