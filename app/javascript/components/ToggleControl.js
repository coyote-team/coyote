export function ToggleControl(control) {
  // Stash the control and its target
  this.control = control
  this.control.addEventListener("click", this.toggle.bind(this))
}

ToggleControl.prototype.press = function (control, unpressSelector, pressed = true) {
  // Mark the control as "pressed"
  control.setAttribute("aria-pressed", pressed)

  // Un-press controls that do the opposite of our friend
  document
    .querySelectorAll(
      `[data-toggle-target='${control.getAttribute("data-toggle-target")}']${unpressSelector}`
    )
    .forEach(otherControl => {
      if (otherControl !== control) {
        otherControl.setAttribute("aria-pressed", !pressed)
      }
    })
}

ToggleControl.prototype.toggle = function (event) {
  // Find the thing we're paying attention to regarding the toggling of classes
  const control = event.currentTarget

  // Find the thing we're toggling classes on
  const target = document.querySelector(control.getAttribute("data-toggle-target"))
  if (!target) {
    return
  }

  // Find what we're toggling on the thing we're toggling classes on
  const classname = control.getAttribute("data-toggle")
  const onClassname = control.getAttribute("data-toggle-on")
  const offClassname = control.getAttribute("data-toggle-off")
  if (!classname && !onClassname && !offClassname) {
    return
  }

  // Okay, we've got something to do AND something to do it to - go ahead and prevent the click
  event.preventDefault()

  // Remove a class
  if (offClassname) {
    target.classList.remove(offClassname)

    // Un-press the other controls that ADD the class we're removing
    this.press(control, `[data-toggle-on='${offClassname}']`)
  }

  // Add a class
  if (onClassname) {
    target.classList.add(onClassname)

    // Un-press the other controls that REMOVE the class we're adding
    this.press(control, `[data-toggle-off='${onClassname}']`)
  }

  // Toggle a class
  if (classname) {
    target.classList.toggle(classname)

    // and the corresponding aria-expanded attribute
    const expanded = target.getAttribute("aria-expanded") !== "true"
    target.setAttribute("aria-expanded", expanded)

    // and the corresponding aria-pressed on the toggle control
    if (target.classList.contains(classname)) {
      this.press(control, `[data-toggle='${classname}']`)
    } else {
      this.press(control, `[data-toggle-off='${classname}']`, false)
    }
  }
}
