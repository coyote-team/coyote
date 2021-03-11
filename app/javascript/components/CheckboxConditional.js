document.querySelectorAll("form input[type=checkbox]").forEach(checkbox => {
  checkbox.addEventListener("change", checkForConditionals)
})

function checkForConditionals(event) {
  const checkbox = event.currentTarget
  if (!checkbox) return

  const form = checkbox.form
  if (!form) return

  const hasChecked = !!form.querySelector("input[type=checkbox]:checked")
  form.querySelectorAll("[data-checkbox-conditional]").forEach(conditional => {
    if (hasChecked) {
      conditional.dataset.checkboxConditionalApplied = true
    } else {
      delete conditional.dataset.checkboxConditionalApplied
    }
  })
}
