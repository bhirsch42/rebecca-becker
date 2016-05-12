if Meteor.isClient
  @categories = null
  @categories = ->
    if categories
      return categories
    categories = {}
    Portraits.find({}).forEach (portrait) ->
      categories[portrait.category] = 1
    categories = (key for key of categories)

  @cloudinaryIdFromUrl = (url) ->
    Meteor.settings.public.cloudinary.folder + '/' + url.split('/')[-1..][0].split('.')[0]

  Template.content.onRendered ->
    $(window).scrollTop 0
    setTimeout ->
      $(window.location.hash).velocity 'scroll',
        duration: 1000
        easing: 'ease-in-out'
    , 400
    console.log 'scrolltop boi'

  Template.nav.onRendered ->
    $('.nav-button').click ->
      $('.side-nav-wrapper').toggleClass 'open'

  # Template.nav.events
  #   'click a': (e) ->
  #     e.preventDefault()

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
          cloudinaryId: cloudinaryIdFromUrl Portraits.findOne(category: category).image.url
          galleryLink: _.escape(category).replace('/', '|||')
        }

  Template.gallery.helpers
    'categories': ->
      selectedCategory = _.unescape(FlowRouter.getParam('category')).replace('|||', '/')
      categories().map (category) ->
        {
          category: category
          galleryLink: _.escape(category).replace('/', '|||')
          selected: if category == selectedCategory then 'selected' else ''
        }

    'allSelected': ->
      selectedCategory = _.unescape(FlowRouter.getParam('category')).replace('|||', '/')
      return if selectedCategory == 'all' then 'selected' else ''


    'portraits': ->
      category = _.unescape(FlowRouter.getParam('category')).replace('|||', '/')
      width = 270

      cursor = Portraits.find(category: category)
      cursor = Portraits.find({}) if cursor.count() == 0
      cursor.map (portrait) ->
        cloudinaryId = cloudinaryIdFromUrl portrait.image.url
        ratio = width / portrait.image.info.width
        # console.log cloudinaryId, width, portrait
        {
          width: width
          height: portrait.image.info.height * ratio
          imageLink: $.cloudinary.image(cloudinaryId, width: width, crop: 'scale')[0].src
        }

      # TESTING
      # width = 270
      # Portraits.find({}).map (portrait) ->
      #   cloudinaryId = cloudinaryIdFromUrl portrait.image.url
      #   ratio = width / portrait.image.info.width
      #   # console.log cloudinaryId, width, portrait
      #   {
      #     width: width
      #     height: portrait.image.info.height * ratio
      #     imageLink: $.cloudinary.image(cloudinaryId, width: width, crop: 'scale')[0].src
      #   }

  @masonry = _.debounce ->
    # $('.grid').masonry({itemSelector: '.grid-item', columnWidth: 300, isFitWidth: true})
    $('.grid').masonry 'destroy'
    $('.grid').masonry({itemSelector: '.grid-item', columnWidth: 300, isFitWidth: true})
  , 20

  # @masonry = ->
  #   $('.grid').css 'width', '100%'
  #   $('.grid').masonry({itemSelector: '.grid-item', columnWidth: 300, isFitWidth: true})
  #   console.log 'Masonry!'

  # Template.gallery.onRendered ->
  #   console.log 'masonry load'
  #   $('.grid').masonry({itemSelector: '.grid-item', columnWidth: 300, isFitWidth: true})

  Template.portrait.onRendered ->
    masonry()


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
