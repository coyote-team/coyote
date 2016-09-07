#Turbolinks.enableProgressBar()
$ ->
  #setSizes = ()->
    #height = $(window).height() - $('#nav').outerHeight()
    #width = $(window).width()
    ##$('section', '#dashboard').css {'height': height}

  #$(window).resize $.debounce 100, ->
      #setSizes()

  $(document).on 'turbolinks:click', ->
    console.log('fade out')
    $('#main').addClass('fadeOut')

  $(document).on 'turbolinks:load', ->

  #$(document).on 'page:restore', ->
    #Analytical.track()

  counter = 0
  $(document).on 'turbolinks:load', ->
    if counter > 0
      Analytical.track()
      $('.stayOut').removeClass('fadeOutSlow')
    counter += 1
    #fade/in out on page transition
    $('#main').removeClass('fadeOut').addClass('fadeIn')
    console.log('fade in')

    $grid = $('.isotope').isotope()

    #pagination on user pages
    $('.paginated-table tbody').pageMe
      pagerSelector:'.pager'
      showPrevNext:true
      hidePageNumbers:false
      perPage:10



    #set focus on flash then shift to page title
    $flash = $('#flash-messages')
    if $flash.text().trim().length > 0
      $flash.attr('tabindex', -1).focus()
      $flash.on 'closed.bs.alert', () ->
        $('#page-title').focus()
    #or just put it on the page title
    else
      $('#page-title').focus()

    #allow file input for csv upload
    $('input[type=file]').bootstrapFileInput()

    #remove :visited attributes on */new for screen readers
    $('a.new-link').removeProp('visited')

    #show instructions per metum on description form
    $('#description_metum_id').off().on 'change',  (e) ->
      metum_id = $(@).find(":selected").val()
      $("#metum-instructions-" + metum_id).slideDown().siblings().slideUp()

    #selectAll
    $('#select-all').click (event) ->
      state =  @checked
      $(':checkbox').each ->
        @checked = state
        return
      return

    #ajax quick-delete
    $('.quick-delete').bind 'ajax:beforeSend', (e) ->
      $(e.currentTarget).html '<i class="fa fa-spinner fa-spin" aria-hidden="true"></i><span class="sr-only">Loading..</span>'
    .bind 'ajax:error', (e) ->
      $(e.currentTarget).html 'There was an error'
    .bind 'ajax:complete', (e) ->
      #$('body').fadeIn()
      $group = $(e.currentTarget).parents('.group').first()
      $countable = $group.find('.countable').first()
      $countable.text(parseInt($countable.text()) - 1)
      $deletable = $(e.currentTarget).parents('.deletable').first()
      $deletable.fadeOut()

    #ajax bulk
    $('.bulk').off().on 'click', (e) ->
      bulk          = $(@).data('bulk') #used for strong params
      url           = $(@).data('url')
      actor         = $(@).data('actor')
      actor_css     = actor.replace(/_/g, '-')
      actor_value   = $(@).data(actor_css)
      selector      = $(@).data('selector')
      selector_name = selector.replace(/_/g, '-')
      selector_css  = '.' + selector_name

      $selections = $('' + selector_css + ":checked")

      sets = []
      for selection in $selections
        set = {}
        set[actor] = actor_value
        set[selector] = $(selection).data(selector_name)
        sets.push set
      data = {}
      data[bulk] = sets

      
      $('#main').addClass('fadeOut')
      console.log('fade out')
      $.ajax
        url: url
        type: "POST"
        data: data
        success: (data) ->
          Turbolinks.visit(window.location)

        error: (jqXHR, textStatus, errorThrown) ->
          alert textStatus, errorThrown
          $('#main').addClass('fadeIn').removeClass('fadeOut')

