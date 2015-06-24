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

    #for ajax boolean toggle
    $('.boolean-toggle').off().on 'click', (e) ->
      $(@).toggleClass 'fa-check'
          .toggleClass 'fa-times'

    #$loading = $('#loading')
    #$og = $('[data-original]')
    #lazy =
      #threshold: 200
      #load: ()->
        #$loading.fadeOut 200,()->
          #$(this).removeClass('loaded')
    #if $og.length > 0
        #$og.lazyload lazy
        #$loading.addClass('active')
    #setSizes()

    ##CAROUSEL
    #afterAction = ()->
      #$elem =$(this)[0].$elem
      ##console.log  $elem.siblings('.arrow.left')

      #currentSlide  = this.owl.currentItem
      #totalSlides   = this.owl.owlItems.length
      #visibleSlides = this.owl.visibleItems
      #realCurrent   = _(visibleSlides).last()+1

      #if currentSlide == 0
        #$elem.siblings('.arrow.left').hide()
      #else
        #$elem.siblings('.arrow.left').show()
      #if realCurrent == totalSlides
        #$elem.siblings('.arrow.right').hide()
      #else
        #$elem.siblings('.arrow.right').show()
    #$(".owl-carousel").owlCarousel
      #navigation : false
      #slideSpeed : 300
      #pagination : false
      #paginationSpeed : 400
      #singleItem: true
      #autoPlay: false
      ##transitionStyle: 'fade'
      #lazyLoad: true
      #afterAction : afterAction
      ##afterInit : afterInit
      #lazyPreloadDisplays : 3
    ##attach click to arrows per carousel
    #$('.arrow.left').on 'click', (e) ->
      #$(e.currentTarget).siblings('.owl-carousel').data('owlCarousel').prev()
    #$('.arrow.right').on 'click', (e) ->
      #$(e.currentTarget).siblings('.owl-carousel').data('owlCarousel').next()
