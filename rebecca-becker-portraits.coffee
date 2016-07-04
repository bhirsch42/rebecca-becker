if Meteor.isClient
  @categories = null
  @categories = ->
    # Extract categories from Portrait colleciton
    # if categories
    #   return categories
    # categories = {}
    # Portraits.find({}).forEach (portrait) ->
    #   categories[portrait.category] = 1
    # categories = (key for key of categories)

    # Parse categories from orion dictionary
    orion.dictionary.get('site.categories').split(',')

  @cloudinaryIdFromUrl = (url) ->
    Meteor.settings.public.cloudinary.folder + '/' + url.split('/')[-1..][0].split('.')[0]

  Template.content.onRendered ->
    $(window).scrollTop 0
    setTimeout ->
      $(window.location.hash).velocity 'scroll',
        duration: 1000
        easing: 'ease-in-out'
    , 400

  # Workaround because click events on mobile Safari are weird
  Template.nav.onRendered ->
    $('.nav-button').click ->
      $('.side-nav-wrapper').toggleClass 'open'
    $('.side-nav-cover').click ->
      $('.side-nav-wrapper').removeClass 'open'
    $('a').click ->
      $('.side-nav-wrapper').removeClass 'open'

  Template.oil_prices.helpers
    'prices': -> OilPrices.find({}, {sort: {'order': 1}})

  Template.pastel_prices.helpers
    'prices': -> PastelPrices.find({}, {sort: {'order': 1}})

  Template.testimonials.helpers
    'testimonials_first': -> Testimonials.find({}, {sort: {'order': 1}}).fetch()[..2]
    'testimonials_rest': -> Testimonials.find({}, {sort: {'order': 1}}).fetch()[3..]

  Template.gallery_launcher.helpers
    'categories': ->
      categories().map (category) ->
        {
          category: category
          cloudinaryId: cloudinaryIdFromUrl Portraits.findOne(category: category, {sort: {'order': 1}}).image.url
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

      cursor = Portraits.find({category: category}, {sort: {'order': 1}})
      if cursor.count() == 0
        cursor = Portraits.find({}).fetch().sort (a, b) ->
          c = categories().indexOf(a.category) - categories().indexOf(b.category)
          if c == 0
            return a.order - b.order
          return c

      cursor.map (portrait) ->
        cloudinaryId = cloudinaryIdFromUrl portrait.image.url
        ratio = width / portrait.image.info.width
        {
          cloudinaryId: cloudinaryId
          width: width
          height: portrait.image.info.height * ratio
          imageLink: $.cloudinary.image(cloudinaryId, width: width, crop: 'scale')[0].src
          caption: portrait.caption
        }

  Template.gallery.onRendered ->
    $('.gallery').addClass 'fadeIn'

  Template.gallery.events
    'click .portrait': (e) ->
      width = 800

      pswp = $('.pswp')[0]

      category = _.unescape(FlowRouter.getParam('category')).replace('|||', '/')

      imageId = $(e.target).closest('.portrait').data('cloudinary-id')

      cursor = Portraits.find({category: category}, {sort: {'order': 1}})
      cursor = Portraits.find({}, {sort: {'order': 1}}) if cursor.count() == 0

      index = 0
      indexFound = false
      items = cursor.map (portrait) ->
        width = portrait.image.info.width # Ignore width limit; Use original resolution
        cloudinaryId = cloudinaryIdFromUrl portrait.image.url
        if cloudinaryId == imageId
          indexFound = true
        if not indexFound
          index += 1

        ratio = width / portrait.image.info.width
        {
          w: width
          h: portrait.image.info.height * ratio
          src: $.cloudinary.image(cloudinaryId, width: width, crop: 'limit')[0].src
        }

      options = index: index

      photoSwipe = new PhotoSwipe pswp, PhotoSwipeUI_Default, items, options
      photoSwipe.init()


  @masonry = _.debounce ->
    $('.grid').masonry 'destroy'
    $('.grid').masonry({itemSelector: '.grid-item', columnWidth: 300, isFitWidth: true})
  , 400

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
