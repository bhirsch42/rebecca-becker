orion.dictionary.addDefinition 'about_the_artist', 'site',
  type: String
  label: 'About the Artist'
  autoform:
    type: 'textarea'

@OilPrices = new orion.collection 'oil_prices',
  singularName: 'custom oil portrait price'
  pluralName: 'custom oil portrait prices'
  title: 'Custom oil portrait prices'
  link:
    title: 'Custom oil portrait prices'

  tabular:
    columns: [
      {data: 'product', title: 'Product'},
      {data: 'price', title: 'Price'},
    ]


OilPrices.attachSchema new SimpleSchema
  product:
    type: String
  price:
    type: String

@PastelPrices = new orion.collection 'pastel_prices',
  singularName: 'custom pastel portrait price'
  pluralName: 'custom pastel portrait prices'
  title: 'Custom pastel portrait prices'
  link:
    title: 'Custom pastel portrait prices'

  tabular:
    columns: [
      {data: 'product', title: 'Product'},
      {data: 'price', title: 'Price'},
    ]


PastelPrices.attachSchema new SimpleSchema
  product:
    type: String
  price:
    type: String
