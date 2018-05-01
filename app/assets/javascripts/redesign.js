//= require_tree ./polyfills
//= require_tree ./components
//= require vendor/bootstrap-native-v4

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
