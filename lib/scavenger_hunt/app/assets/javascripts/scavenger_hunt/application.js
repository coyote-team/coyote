//= require accessible-autocomplete.min.js

(function() {
  document.querySelectorAll(".autocomplete").forEach(function(autocomplete) {
    var endpoint = autocomplete.dataset.endpoint
    var input = document.querySelector(autocomplete.dataset.input)
    var placeholder = autocomplete.dataset.placeholder

    accessibleAutocomplete({
      placeholder: placeholder,
      autoselect: false,
      element: autocomplete,
      id: 'q', // To match it to the existing <label>.
      name: 'q',
      onConfirm: function(value) {
        if (value) {
          input.value = value.id
          input.form.submit()
        }
      },
      required: true,
      showNoResultsFound: false,
      source: function(query, callback) {
        fetch(endpoint + "?q=" + query, {
          credentials: "same-origin"
        }).then(function(response) {
          return response.json()
        }).then(function(results) {
          callback(results)
        })
      },
      templates: {
        inputValue: function(input) { return input && input.title },
        suggestion: function(suggestion) { return suggestion && suggestion.title }
      }
    })
  })

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
