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
      #initSelection: (element, callback) ->
        #saved and callback(saved)

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

# Override Rails handling of confirmation
# https://gist.github.com/postpostmodern/1862479
$.rails.allowAction = (element) ->
  # The message is something like "Are you sure?"
  message = element.data('confirm')
  # If there's no message, there's no data-confirm attribute, 
  # which means there's nothing to confirm
  return true unless message
  # Clone the clicked element (probably a delete link) so we can use it in the dialog box.
  $link = element.clone()
    # We don't necessarily want the same styling as the original link/button.
    .removeAttr('class')
    # We don't want to pop up another confirmation (recursion)
    .removeAttr('data-confirm')
    # data-dismiss property is required for remote links
    # .attr('data-dismiss', 'modal')
    # We want a button
    .addClass('btn').addClass('btn-danger')
    # We want it to sound confirmy
    .html("<i class='fa fa-fw fa-trash'></i> Yes")

    # Create the modal box with the message
    modal_html = """
               <div id="myModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
                <div class="modal-dialog">
                  <div class="modal-content">                
                    <div class="modal-header">
                   <button type="button" class="close" title="Dismiss this modal" data-dismiss="modal">×</button>
                   <h3 id="myModalLabel">#{message}</h3>
                 </div>
<!--                 <div class="modal-body">
                   <p>Are you sure you want to do this?</p>
                 </div> -->
                 <div class="modal-footer">
                   <button class="btn" data-dismiss="modal" aria-hidden="true">Cancel</button>
                 </div>
               </div>
              </div>
             </div>  
               """
  $modal_html = $(modal_html)
  # Add the new button to the modal box
  $modal_html.find('.modal-footer').append($link)
  # Pop it up
  $modal_html.modal()
  # Prevent the original link from working
  return false
