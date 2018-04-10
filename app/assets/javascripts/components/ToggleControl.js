function ToggleControl(control) {
  // Stash the control and its items
  this.target = document.querySelector(control.getAttribute("data-toggle-target"));

  this.toggles = control.querySelectorAll("[data-toggle-target-on], [data-toggle-target-off]");
  this.toggles.forEach(this.watch.bind(this));
}

ToggleControl.prototype.watch = function(toggle) {
  var on = toggle.getAttribute("data-toggle-target-on");
  var off = toggle.getAttribute("data-toggle-target-off");
  toggle.addEventListener("click", function() {
    if (off) {
      this.target.classList.remove(off);
    }

    if (on) {
      this.target.classList.add(on);
    }
  }.bind(this));
};
