//= require easymarklet/consumer
//= require coyote_bookmarklet

var coyote_consumer = new Easymarklet.Consumer(CoyoteBookmarklet);
coyote_consumer.init();

//TODO
//create website object
//lookup website in coyote
//tell user to login if access token fails
//create if doesn't exist
//look up and insert descriptions
//if no descriptions found
var $coyote_overlay = $('<div id="coyote-overlay"></div>');
var $coyote_items = $('<div id="coyote-items"></div>');
var $coyote_header = $('<div id="coyote-header"></div>');
$coyote_header.append('<h1>Welcome</h1>');
$('img, picture').each(function(){
  //console.log('adding');
  //console.log(this);
  var $clone = $(this).clone();
  var $item = $('<div class="item"></div>');
  //TODO make ajax request with button
  //TODO hand off to buffer?
  var $link = $('<a href="http://google.com" target="_blank">Describe</a>');
    $item
      .append($clone)
      .append($link)
      .appendTo($coyote_items);
});
$coyote_overlay.append($coyote_items);
$coyote_overlay.appendTo($('body'));

