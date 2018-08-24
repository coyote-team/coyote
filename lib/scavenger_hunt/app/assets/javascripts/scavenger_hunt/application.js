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
})()
