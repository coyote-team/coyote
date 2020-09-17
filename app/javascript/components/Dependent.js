function requireInput(input) {
  input.required = true
  if (input.dataset.customValidity) {
    input.setCustomValidity(
      input.dataset.customValidity ||
        input.dataset.originalValidationMessage ||
        input.validationMessage
    )
  }
}

function unrequireInput(input) {
  input.dataset.originalValidationMessage = input.validationMessage
  input.required = false
  if (input.dataset.customValidity) {
    input.setCustomValidity("")
  }
}

let parents = new Set()

/*
  An element that is "dependent on" another will be made visible, and if it's an input (or contains child inputs)
  have `required` attributes toggled, as the input on which it depends changes value.

  `data-depends-on` is expected to provide an input name and value separated by a colon, e.g.
  `data-depends-on="opportunity[status]:closed"`.
*/
document
  .querySelectorAll("[data-dependent-on], [data-required-when], [data-required-when-all]")
  .forEach(element => {
    // Find the name of the input this dependent is dependent upon (its "parent"). Either the "dependent-on" or the
    // "required-when" flags will trigger this.
    const { dependentOn, requiredWhen, requiredWhenAll } = element.dataset
    const parentSelector = dependentOn || requiredWhen || requiredWhenAll

    parentSelector.split(" ").forEach(parent => {
      const [name, _] = parent.split(":")
      parents.add(name)
    })
  })

watchParents()

function watchParents() {
  // Iterate through each individual parent and watch their dependents
  parents.forEach(name => {
    const selector = `[name="${name}"]`

    // Find the first NON-HIDDEN input to see if it's a combination of hidden (default) / checkbox
    // (override) - and fall back to the hidden one
    const input =
      document.querySelector(`${selector}:not([type="hidden"])`) || document.querySelector(selector)
    if (input) {
      let type = input.tagName.toLowerCase() === "input" ? input.type : "input"

      if (type === "checkbox") {
        // Check for a toggle checkbox - which is 1 hidden + 1 checkbox
        const hidden = document.querySelector(`${selector}[type="hidden"]`)
        if (hidden && document.querySelectorAll(`input${selector}`).length === 2) {
          // Treat toggles as radio buttons
          type = "radio"
        }
      }

      // Watch ALL inputs for changes
      document.querySelectorAll(selector).forEach(input => watchParent(input, type))
    }
  })

  // Reset parents so subsequent applications of this function don't duplicate the mutation observers
  parents = new Set()
}

function filterElements(elements, from) {
  return elements.filter(element => !from.includes(element))
}

function watchParent(input, type) {
  // Determine if we're in a multi-input scenario (checkboxes / radio buttons) vs. standard, single-value inputs (any
  // other <input /> tag, or <select /> or <textarea /> tags)
  const { name } = input

  // Watch the input for changes to toggle / untoggle its dependents
  input.addEventListener("change", () => {
    // Toggle dependents based on the parent's value. Uses this logic:
    // Radio buttons: look for the first CHECKED value, falling back to the first rendered
    // Checkboxes: look only for dependents on that explicit value; ignore others
    // Anything else: look for dependents on its value, un-toggle anything else
    let hideSelector
    let showSelector

    switch (type) {
      case "checkbox":
        const selector = `${name}:${input.value}`
        if (input.checked) {
          showSelector = selector
        } else {
          hideSelector = selector
        }
        break
      case "radio":
        const { value } =
          document.querySelector(`input[name="${name}"]:checked`) ||
          document.querySelector(`input[name="${name}"]`)
        showSelector = `${name}:${value}`
        hideSelector = name
        break
      default:
        showSelector = `${name}:${input.value}`
        hideSelector = name
        break
    }

    // Find elements to show and require
    const show = showSelector
      ? Array.from(document.querySelectorAll(`[data-dependent-on~="${showSelector}"]`))
      : []

    const require = showSelector
      ? Array.from(document.querySelectorAll(`[data-required-when~="${showSelector}"]`))
      : []

    // Find elements to hide and unrequire - excluding anything that is being shown / required
    const hide = hideSelector
      ? filterElements(
          Array.from(document.querySelectorAll(`[data-dependent-on*="${hideSelector}"]`)),
          show.concat(require)
        )
      : []

    const unrequire = hideSelector
      ? filterElements(
          Array.from(document.querySelectorAll(`[data-required-when*="${hideSelector}"]`)).filter(
            element => !require.includes(element) && !show.includes(element)
          ),
          show.concat(require)
        )
      : []

    // Find elements with compound dependencies (the above represents "any", this is "all")
    const requireAll = Array.from(document.querySelectorAll(`[data-required-when-all*="${name}"]`))

    // First, hide dependents that needs hiding and unrequire their children
    hide.forEach(element => {
      // Hide it
      element.style.display = "none"

      // Prevent the dependent from being required now that it's hidden
      if (element.getAttribute("required")) {
        unrequire(element)
      }

      // Prevent its descendents from being required if they are hidden
      element.querySelectorAll("[required]").forEach(unrequireInput)
    })

    // Second, show dependents and restore their requirements
    show.forEach(element => {
      // Show it
      element.style.display = ""

      // Re-require it
      if (element.dataset.originalValidationMessage) {
        requireInput(element)
      }

      // Restore its descendents' previous requirements
      element.querySelectorAll("[data-original-validation-message]").forEach(requireInput)
    })

    // Third, require / unrequire any explicit `data-required-when`'s
    require.forEach(requireInput)
    unrequire.forEach(unrequireInput)

    // Finally, require / unrequire any `data-required-when-all`'s who meet ALL the criteria
    requireAll.forEach(require => {
      const { requiredWhenAll } = require.dataset
      const allRequirementsMet = requiredWhenAll.split(" ").every(requirement => {
        const [name, value] = requirement.split(":")
        const input = document.querySelector(`[name="${name}"]`)
        return input.value.toString() === value
      })

      if (allRequirementsMet) {
        requireInput(require)
      } else {
        unrequireInput(require)
      }
    })
  })

  input.dispatchEvent(new InputEvent("change"))
}
