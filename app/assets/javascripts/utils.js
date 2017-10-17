// from https://coderwall.com/p/4fbluw/rails-twitter-bootstrap-and-disabled-links-buttons

$(document).ready(function() {
    $('a[disabled=disabled]').click(function(event){
        event.preventDefault(); // Prevent link from following its href
    });
});
