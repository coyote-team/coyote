export function Tabs(list) {
  this.list = list
  this.changeTab = this.changeTab.bind(this)
  this.moveTabFocus = this.moveTabFocus.bind(this)
  this.selectTab = this.selectTab.bind(this)

  this.tabs = this.list.querySelectorAll("[role=tab]")
  if (this.tabs.length > 0) {
    this.tabs.forEach((tab, index) => {
      // Listen for tab changes
      tab.addEventListener("click", this.changeTab)

      // Stash the selected tab
      if (tab.getAttribute("aria-selected") == "true") {
        this.selected = index
      }
    })

    // Select the first tab if none have opted-in to being selected
    if (typeof this.selected == "undefined") {
      this.selected = 0
      this.selectTab(this.tabs[0])
    }

    // Allow keyboard navigation
    this.list.addEventListener("keydown", this.moveTabFocus)
  }
}

Tabs.prototype.changeTab = function (event) {
  event.preventDefault()
  this.selectTab(event.target)
}

Tabs.prototype.moveTabFocus = function (event) {
  // Move right
  const { keyCode } = event
  if (keyCode === 39 || keyCode === 37) {
    this.tabs[this.selected].setAttribute("tabindex", "-1")

    if (keyCode === 39) {
      // Move right
      this.selected++

      // If we're at the end, go to the start
      if (this.selected >= this.tabs.length) {
        this.selected = 0
      }
    } else {
      this.selected--

      // If we're at the start, move to the end
      if (this.selected < 0) {
        this.selected = this.tabs.length - 1
      }
    }

    const tab = this.tabs[this.selected]
    tab.setAttribute("tabindex", 0)
    tab.focus()
  }
}

Tabs.prototype.selectTab = function (tab) {
  // Toggle the selected tab
  this.tabs.forEach(otherTab => {
    const isCurrentTab = otherTab == tab
    otherTab.setAttribute("aria-selected", isCurrentTab)
    const panel = document.getElementById(otherTab.getAttribute("aria-controls"))
    if (isCurrentTab) {
      panel.removeAttribute("hidden")
    } else {
      panel.setAttribute("hidden", panel.id == tab.getAttribute("aria-controls"))
    }
  })
}
