// Make radio buttons un-checkable
export function RadioButton(control) {
  this.control = control
  this.control.dataset.checked = this.control.checked
  this.control.addEventListener("change", this.change.bind(this))
  this.control.addEventListener("click", this.check.bind(this))
}

RadioButton.prototype.change = function () {
  setTimeout(() => {
    document.querySelectorAll(`input[type=radio][name="${this.control.name}"]`).forEach(input => {
      input.dataset.checked = input.checked
    })
  }, 1)
}

RadioButton.prototype.check = function () {
  // Deselect controls that were checked previously
  if (this.control.checked && this.control.dataset.checked == "true") {
    this.control.checked = false
  }
}
