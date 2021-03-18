document.querySelectorAll("form input[type=checkbox]").forEach(checkbox => {
  checkbox.addEventListener("change", checkForConditionals)
})

function checkForConditionals(event) {
  const checkbox = event.currentTarget
  if (!checkbox) return

  const form = checkbox.form
  if (!form) return

  const checked = form.querySelectorAll("input[type=checkbox]:not([data-select-all]):checked")
    .length
  const hasChecked = checked > 0

  form.querySelectorAll("[data-checkbox-conditional]").forEach(conditional => {
    if (hasChecked) {
      conditional.dataset.checkboxConditionalApplied = true
    } else {
      delete conditional.dataset.checkboxConditionalApplied
    }
  })

  form.querySelectorAll("[data-checkbox-conditional-prefix]").forEach(counter => {
    if (hasChecked) {
      counter.dataset.checkboxConditionalCount = checked
    } else {
      delete counter.dataset.checkboxConditionalCount
    }
  })
}
