export function SelectAll(control) {
  // Stash a reference to the checkbox that does the stuff
  this.control =
    control.tagName.toLowerCase() == "input"
      ? control
      : control.querySelector("input:not([type=hidden])")

  // Stash a reference to all of the checkboxes inside the `data-select-all`
  // target
  const inputSelector = control.getAttribute("data-select-all") + " input[type=checkbox]"
  this.inputs = Array.from(document.querySelectorAll(inputSelector))

  // Stash a reference to all of the checkboxes inside the target that AREN'T
  // select-all checkboxes
  this.childInputs = Array.from(
    document.querySelectorAll(inputSelector + ":not([data-select-all])")
  )

  // Have the "Select all" control update all other inputs
  this.control.addEventListener("click", this.selectAll.bind(this))

  // Have all the OTHER inputs deselect the select-all inputs when they change
  this.childInputs.forEach(input => {
    input.addEventListener("click", this.update.bind(this))
  })
}

SelectAll.prototype.selectAll = function () {
  // First just make sure everything matches the trigger input
  this.inputs.forEach(input => (input.checked = this.control.checked))
}

SelectAll.prototype.update = function () {
  this.control.checked = this.childInputs.every(input => !!input.checked)
}
