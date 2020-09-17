export function Lightbox(link) {
  this.url = link.dataset["lightbox"]
  this.open = this.open.bind(this)
  this.close = this.close.bind(this)
  link.addEventListener("click", this.open)
}

Lightbox.prototype.open = function (event) {
  event.preventDefault()

  // Build the container
  this.container = document.createElement("div")
  this.container.className = "lightbox"

  // Build the image
  var image = document.createElement("img")
  image.src = this.url
  image.className = "lightbox-item"
  this.container.appendChild(image)

  // Make sure it can be closed
  this.container.addEventListener("click", this.close)
  document.addEventListener("keydown", this.close)

  // Present the container
  document.body.appendChild(this.container)
}

Lightbox.prototype.close = function (event) {
  if (
    event.constructor !== KeyboardEvent ||
    (event.constructor === KeyboardEvent && event.keyCode === 27)
  ) {
    if (this.container && this.container.parentNode) {
      this.container.removeEventListener("click", this.close)
    }

    document.removeEventListener("keydown", this.close)
    this.container.parentNode.removeChild(this.container)
  }
}
