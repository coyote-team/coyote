function SegmentedControl(control) {
  // Stash the control and its items
  this.control = control;
  this.items = this.control.querySelectorAll(".segmented-control-item");

  // Watch the items for changes
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
