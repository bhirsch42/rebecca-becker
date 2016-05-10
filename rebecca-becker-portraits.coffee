if Meteor.isClient
  @categories = null
  @categories = ->
    if categories
      return categories
    categories = {}
    Portraits.find({}).forEach (portrait) ->
      categories[portrait.category] = 1
    categories = (key for key of categories)

  Template.nav.onRendered ->
    $('.nav-button').click ->
      $('.side-nav-wrapper').toggleClass 'open'

  Template.oil_prices.helpers
    'prices': -> OilPrices.find({})

  Template.pastel_prices.helpers
    'prices': -> PastelPrices.find({})

  Template.testimonials.helpers
    'testimonials_first': -> Testimonials.find({}).fetch()[..2]
    'testimonials_rest': -> Testimonials.find({}).fetch()[3..]

  Template.gallery_launcher.helpers
    'categories': ->
      categories().map (category) ->
        {
          category: category
          cloudinaryId: Meteor.settings.public.cloudinary.folder + '/' + Portraits.findOne(category: category).image.url.split('/')[-1..][0].split('.')[0]
          galleryLink: _.escape(category).replace('/', '|||')
        }

  Template.gallery.helpers
    'categories_first': ->
      categories().slice(0, 1)

    'categories_rest': ->
      console.log 'categories()', categories()
      console.log 'categories().slice(1)', categories().slice(1)
      categories().slice(1)

    'portraits_top': ->
      portraits = Portraits.find {category: categories()[0]}
      splitPortraits = {top: [], bottom: []}
      topWidth = 0
      bottomWidth = 0
      portraits.forEach (p) ->
        if topWidth > bottomWidth
          bottomWidth += p.image.info.width / p.image.info.height
          splitPortraits.bottom.push p
        else
          topWidth += p.image.info.width / p.image.info.height
          splitPortraits.top.push p
      return splitPortraits.top

    'portraits_bottom': ->
      portraits = Portraits.find {category: categories()[0]}
      splitPortraits = {top: [], bottom: []}
      topWidth = 0
      bottomWidth = 0
      portraits.forEach (p) ->
        if topWidth > bottomWidth
          bottomWidth += p.image.info.width / p.image.info.height
          splitPortraits.bottom.push p
        else
          topWidth += p.image.info.width / p.image.info.height
          splitPortraits.top.push p
      return splitPortraits.bottom


  Template.gallery.events
    'click span.category': (e) ->
      $('.selected').removeClass 'selected'
      $(e.target).closest('li').addClass 'selected'
      category = $(e.target).data 'category'
      portraits = Portraits.find {category: category}

      splitPortraits = {top: [], bottom: []}

      topWidth = 0
      bottomWidth = 0

      portraits.forEach (p) ->
        if topWidth > bottomWidth
          bottomWidth += p.image.info.width / p.image.info.height
          splitPortraits.bottom.push p
        else
          topWidth += p.image.info.width / p.image.info.height
          splitPortraits.top.push p

      $('#top').empty()
      $('#bottom').empty()

      Blaze.renderWithData Template.portraits, portraits: splitPortraits.top, $('#top')[0]
      Blaze.renderWithData Template.portraits, portraits: splitPortraits.bottom, $('#bottom')[0]
      $(".fancybox").fancybox()

  Template.testimonials.events
    'click #more-testimonials': (e) ->
      $('#more-testimonials').hide()
      $('#fewer-testimonials').show()
      $expandable = $('.expandable-wrapper')
      $expandableChild = $expandable.find '.expandable'
      $expandable.velocity
        height: $expandableChild.height()
      ,
        duration: 400

    'click #fewer-testimonials': (e) ->
      $('#fewer-testimonials').hide()
      $('#more-testimonials').show()
      $expandable = $('.expandable-wrapper')
      $expandableChild = $expandable.find '.expandable'
      $expandable.velocity
        height: 0
      ,
        duration: 400

  # Template.testimonials.rendered = ->
  #   $('.testimonials').masonry({itemSelector: '.testimonial-wrapper', columnWidth: 400})

  Template.photoswipe.rendered = ->
    pswpElement = document.querySelectorAll('.pswp')[0]
    # build items array
    items = [
      {
        src: 'https://placekitten.com/600/400'
        w: 600
        h: 400
      }
      {
        src: 'https://placekitten.com/1200/900'
        w: 1200
        h: 900
      }
    ]
    # define options (if needed)
    options = index: 0
    # Initializes and opens PhotoSwipe
    gallery = new PhotoSwipe(pswpElement, PhotoSwipeUI_Default, items, options)
    gallery.init()
