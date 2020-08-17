export function List(container) {
  // Stash the control and its items
  this.container = container
  this.items = this.container.children

  if (typeof MutationObserver !== "undefined") {
    // Use the MutationObserver class to monitor changes to the dom element
    var observer = new MutationObserver(this.calculateRows.bind(this))
    observer.observe(container, {
      attributeFilter: ["class"],
      attributes: true,
    })

    // Also monitor for window resize events
    window.addEventListener("resize", this.calculateRows.bind(this))

    // Finally, just calculate everything RFN
    this.calculateRows()
  }
}

List.prototype.calculateRows = function (mutation) {
  if (this.container.classList.contains("list--grid")) {
    for (var i = 0; i < this.container.children.length; i++) {
      var child = this.container.children[i]
      this.calculateRowForItem(child)
      imagesLoaded(child, this.calculateRowForItemOnImageLoad.bind(this))
    }
  }
}

List.prototype.calculateRowForItem = function (item) {
  const rowHeightValue = window.getComputedStyle(this.container).getPropertyValue("grid-auto-rows")
  var rowHeight = parseInt(rowHeightValue)
  var rowGap = parseInt(window.getComputedStyle(this.container).getPropertyValue("grid-row-gap"))
  var rowSpan = Math.ceil((item.scrollHeight + rowGap) / (rowHeight + rowGap))
  item.style.gridRowEnd = "span " + rowSpan
}

List.prototype.calculateRowForItemOnImageLoad = function (loaded) {
  this.calculateRowForItem(loaded.elements[0])
}
