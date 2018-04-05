//= require vendor/bootstrap-native-v4

function SegmentedControl(control) {
  this.control = control;
  this.items = this.control.querySelectorAll(".segmented-control-item");
  this.items.forEach(function(item) {
    item.addEventListener("click", function(event) {
      var isPressed = item["aria-pressed"] == "true";
      this.items.forEach(function(otherItem) {
        otherItem.setAttribute("aria-pressed", "false");
      });
      item.setAttribute("aria-pressed", isPressed ? "false" : "true");
    }.bind(this));
  }.bind(this));
}

document.querySelectorAll(".segmented-control").forEach(function(control) {
  var segmentedControl = new SegmentedControl(control);
});
