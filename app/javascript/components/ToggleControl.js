export function ToggleControl(control) {
  // Stash the control and its items
  this.target = document.querySelector(control.getAttribute("data-toggle-target"))

  const toggleSelector = "[data-toggle], [data-toggle-target-on], [data-toggle-target-off]"
  this.toggles = control.querySelectorAll(toggleSelector)
  this.toggles.forEach(this.watch.bind(this))
}

ToggleControl.prototype.watch = function (toggle) {
  var classname = toggle.getAttribute("data-toggle")
  var on = toggle.getAttribute("data-toggle-target-on")
  var off = toggle.getAttribute("data-toggle-target-off")
  toggle.addEventListener("click", () => {
    if (off) {
      this.target.classList.remove(off)
    }

    if (on) {
      this.target.classList.add(on)
    }

    if (classname) {
      this.target.classList.toggle(classname)
    }
  })
}
