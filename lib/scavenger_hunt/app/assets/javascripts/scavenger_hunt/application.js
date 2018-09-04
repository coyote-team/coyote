(function() {
  document.querySelectorAll("a.survey-option").forEach(function(a) {
    a.addEventListener("click", function(event) {
      event.preventDefault()
      fetch(a.href, {
        credentials: "same-origin"
      }).then(function() {
        var options = a.parentNode
        var active = options.querySelectorAll(".survey-option--active")
        active.forEach(function(option) { option.classList.remove("survey-option--active") })
        a.classList.add("survey-option--active")
      })
    })
  })

  document.querySelectorAll("input.survey-answer").forEach(function(input) {
    input.addEventListener("change", function(event) {
      event.preventDefault()
      input.blur()
      fetch(input.dataset.uri + "?answer=" + encodeURIComponent(input.value), {
        credentials: "same-origin"
      }).then(function() {
        var parent = input.parentNode
        parent.querySelectorAll(".survey-answer-message").forEach(child => parent.removeChild(child))
        var message = document.createElement("div")
        message.className = "survey-answer-message"
        message.innerHTML = "Thanks for your input!"
        input.parentNode.appendChild(message)
      })
    })
  })
})()
