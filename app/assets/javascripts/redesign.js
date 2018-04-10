//= require components/SegmentedControl
//= require components/SelectAll
//= require components/ToggleControl
//= require vendor/bootstrap-native-v4

document.querySelectorAll(".segmented-control").forEach(function(control) {
  var segmentedControl = new SegmentedControl(control);
});

document.querySelectorAll("[data-select-all]").forEach(function(control) {
  var selectAll = new SelectAll(control);
});

document.querySelectorAll("[data-toggle-target]").forEach(function(control) {
  var toggle = new ToggleControl(control);
});
