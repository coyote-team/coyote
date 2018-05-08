// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require_tree ./polyfills
//= require_tree ./components
//= require vendor/bootstrap-native-v4
//= require vendor/rollbar
//= require vanilla-ujs

(function() {
  document.querySelectorAll(".list").forEach(function(control) {
    var list = new List(control);
  });

  document.querySelectorAll(".segmented-control").forEach(function(control) {
    var segmentedControl = new SegmentedControl(control);
  });

  document.querySelectorAll("[data-select-all]").forEach(function(control) {
    var selectAll = new SelectAll(control);
  });

  document.querySelectorAll("[data-toggle-target]").forEach(function(control) {
    var toggle = new ToggleControl(control);
  });
})();
