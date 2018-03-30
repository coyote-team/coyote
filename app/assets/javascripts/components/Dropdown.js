window.Dropdown = function(container) {
  this.container = container;
  this.button = container.querySelector(".dropdown-toggle");
  this.menu = container.querySelector(".dropdown-menu");

  this.button.addEventListener("click", this.show.bind(this));
  this.menu.addEventListener("focusout", this.hide.bind(this));
}

window.Dropdown.prototype.hide = function(event) {
  var target = event.relatedTarget;

  if (target !== this.container && !this.container.contains(target)) {
    this.button.setAttribute("aria-expanded", false);
  }
};

window.Dropdown.prototype.show = function(event) {
  event.preventDefault();
  this.button.setAttribute("aria-expanded", true);
  this.menu.focus();
};
