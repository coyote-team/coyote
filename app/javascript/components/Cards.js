export function Cards(container) {
  // Stash the control
  this.container = container
  this.body = this.container.querySelector("tbody")

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

Cards.prototype.calculateRows = function () {
  if (this.renderAsCards()) {
    const rows = this.body.querySelectorAll("tr")
    for (var i = 0; i < rows.length; i++) {
      var child = rows[i]
      this.calculateRowForItem(child)
      imagesLoaded(child, this.calculateRowForItemOnImageLoad.bind(this))
    }
  }
}

Cards.prototype.calculateRowForItem = function (item) {
  const rowHeightValue = window.getComputedStyle(this.body).getPropertyValue("grid-auto-rows")
  var rowHeight = parseInt(rowHeightValue)
  var rowGap = parseInt(window.getComputedStyle(this.body).getPropertyValue("grid-row-gap"))
  var rowSpan = Math.ceil((item.scrollHeight + rowGap) / (rowHeight + rowGap))
  item.style.gridRowEnd = "span " + rowSpan
}

Cards.prototype.calculateRowForItemOnImageLoad = function (loaded) {
  this.calculateRowForItem(loaded.elements[0])
}

Cards.prototype.renderAsCards = function () {
  return this.container.classList.contains("table--cards") || window.innerWidth <= 1024
}
