import * as ActiveStorage from "@rails/activestorage"
import UJS from "@rails/ujs"

import "../polyfills"
import {
  Lightbox,
  List,
  SegmentedControl,
  SelectAll,
  Table,
  Tabs,
  ToggleControl,
} from "../components"

// Boot up the Rails helpers
ActiveStorage.start()
UJS.start()

// Boot up our components
document.querySelectorAll("[data-lightbox]").forEach(function (link) {
  const _ = new Lightbox(link)
})

document.querySelectorAll(".list").forEach(function (control) {
  const _ = new List(control)
})

document.querySelectorAll(".segmented-control").forEach(function (control) {
  const _ = new SegmentedControl(control)
})

document.querySelectorAll("[data-select-all]").forEach(function (control) {
  const _ = new SelectAll(control)
})

document.querySelectorAll("table").forEach(function (control) {
  const _ = new Table(control)
})

// document.querySelectorAll("textarea").forEach(function(control) {
//   const _ = new TextArea(control)
// })

document.querySelectorAll("[role=tablist]").forEach(tabs => new Tabs(tabs))

document.querySelectorAll("[data-toggle-target]").forEach(function (control) {
  const _ = new ToggleControl(control)
})
