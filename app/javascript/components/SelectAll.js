export function SelectAll(control) {
  this.control = control
  this.control.addEventListener("click", this.check.bind(this))
  const inputSelector = control.getAttribute("data-select-all") + " input[type=checkbox]"
  this.inputs = document.querySelectorAll(inputSelector)
}

SelectAll.prototype.check = function () {
  this.inputs.forEach(input => (input.checked = this.control.checked))
}
