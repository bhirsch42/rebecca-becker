if Meteor.isClient
  Template.oil_prices.helpers
    'prices': -> OilPrices.find({})

  Template.pastel_prices.helpers
    'prices': -> PastelPrices.find({})
