export function SegmentedControl(control) {
  // Stash the control and its items
  this.control = control
  this.items = this.control.querySelectorAll(".segmented-control-item > *:first-child")

  // Watch the items for changes
  this.items.forEach(item =>
    item.addEventListener("click", () => {
      var isPressed = item["aria-pressed"] == "true"
      this.items.forEach(otherItem => otherItem.setAttribute("aria-pressed", "false"))
      item.setAttribute("aria-pressed", isPressed ? "false" : "true")
    })
  )
}
