function TextArea(input) {
  this.input = input;
  this.watch();
}

TextArea.prototype.watch = function() {
  var watch = function() {
    this.input.style["height"] = this.input.scrollHeight.toString() + "px";
  }.bind(this)

  this.input.addEventListener("blur", watch);
  this.input.addEventListener("change", watch);
  this.input.addEventListener("focus", watch);
  this.input.addEventListener("keyup", watch);
}
