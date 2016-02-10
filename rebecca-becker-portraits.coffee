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
    'testimonials': -> Testimonials.find({})

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
