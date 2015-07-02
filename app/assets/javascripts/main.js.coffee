$ ->
  #setSizes = ()->
    #height = $(window).height() - $('#nav').outerHeight()
    #width = $(window).width()
    ##$('section', '#dashboard').css {'height': height}

  #$(window).resize $.debounce 100, ->
      #setSizes()

  #$(document).on 'page:fetch', ->
    #$('#loading').fadeIn 'fast'

  $(document).on 'page:load', ->
    Analytical.track()

  $(document).on 'page:restore', ->
    Analytical.track()

  $(document).on 'page:change', ->
    #set focus
    $('#page-title').focus()

    #allow file input for csv upload
    $('input[type=file]').bootstrapFileInput()

    #remove :visited attributes on */new for screen readers
    $('a.new-link').removeProp('visited')


    #for ajax boolean toggle
    $('.boolean-toggle').off().on 'click', (e) ->
      $(@).toggleClass 'fa-check'
          .toggleClass 'fa-times'
