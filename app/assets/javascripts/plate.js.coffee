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
      theme: 'bootstrap'
      placeholder: placeholder
      tokenSeparators: ','
      minimumInputLength: 1

  $priorityToggles = $('a.priority-toggle')
  $priorityToggles.off().click ->
    if $(@).hasClass('label-priority')
      $(@).addClass('label-default').removeClass('label-priority').text("None")
    else
      $(@).addClass('label-priority').removeClass('label-default').text("High")

  $booleanToggles = $('a.boolean-toggle')
  $booleanToggles.off().click ->
    if $(@).find('i').hasClass('fa-check')
      $(@).find('span').text('False')
    else
      $(@).find('span').text('True')
    $(@).find('i').toggleClass('fa-check')
    $(@).find('i').toggleClass('fa-close')

  initMarkdownToolbar = () ->
    $('textarea.wmd-input').each (i, input) ->
      #console.log(input)
      unless $(input).data('initialized')
        attr = $(input).attr('id').split('wmd-input')[1]
        converter = new Markdown.Converter()
        Markdown.Extra.init(converter)
        help =
          handler: () ->
            window.open('http://daringfireball.net/projects/markdown/syntax')
            return false
          title: "<%= I18n.t('components.markdown_editor.help', default: 'Markdown Editing Help') %>"
        editor = new Markdown.Editor(converter, attr, help)
        editor.run()
        $(input).data('initialized', true)
  initMarkdownToolbar()

$(document).on 'turbolinks:load', ->
  plate()

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
