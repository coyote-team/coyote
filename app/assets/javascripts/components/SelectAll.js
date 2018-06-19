function SelectAll(control) {
  this.control = control;
  this.control.addEventListener("click", this.check.bind(this));
  this.inputs = document.querySelectorAll(control.getAttribute("data-select-all") + " input[type=checkbox]");
}

SelectAll.prototype.check = function() {
  this.inputs.forEach(function(input) {
    input.checked = this.control.checked;
  }.bind(this));
}
