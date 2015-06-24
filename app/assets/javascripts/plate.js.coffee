plate =() ->
  #REGEX
  #http://james.padolsey.com/javascript/regex-selector-for-jquery/
  jQuery.expr[":"].regex = (elem, index, match) ->
    matchParams = match[3].split(",")
    validLabels = /^(data|css):/
    attr =
      method: (if matchParams[0].match(validLabels) then matchParams[0].split(":")[0] else "attr")
      property: matchParams.shift().replace(validLabels, "")

    regexFlags = "ig"
    regex = new RegExp(matchParams.join("").replace(/^\s+|\s+$/g, ""), regexFlags)
    regex.test jQuery(elem)[attr.method](attr.property)


  #TAGGABLE w/ AUTOCOMPLETE
  #http://stackoverflow.com/questions/18858328/select2-tag-re-ordering-and-acts-as-taggable-on-gem
  #$('#project_tag_list').select2({tags:[]})
  #http://hoff2.com/2013/11/09/acts_as_taggable_on_active_admin_select2.html
  $('.autocomplete').each (i, autocomplete) ->
    $autocomplete = $(autocomplete)
    placeholder = $autocomplete.data("placeholder")
    url = $autocomplete.data("url")
    saved = $autocomplete.data("saved")
    $autocomplete.select2
      tags: true
      placeholder: placeholder
      minimumInputLength: 1
      initSelection: (element, callback) ->
        saved and callback(saved)

      ajax:
        url: url
        dataType: "json"
        data: (term) ->
          q: term

        results: (data) ->
          results: data

      createSearchChoice: (term, data) ->
        if $(data).filter(->
          @name.localeCompare(term) is 0
        ).length is 0
          id: term
          name: term

      formatResult: (item, page) ->
        item.name

      formatSelection: (item, page) ->
        item.name

  $booleanToggles = $('i.boolean-toggle')
  $booleanToggles.off().click ->
    $(@).toggleClass('fa-check')
    $(@).toggleClass('fa-times')

$(document).on('page:change', plate)
