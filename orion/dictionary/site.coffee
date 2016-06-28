orion.dictionary.addDefinition 'about_the_artist', 'site',
  type: String
  label: 'About the Artist'
  autoform:
    type: 'textarea'

orion.dictionary.addDefinition 'portrait_process', 'site',
  type: String
  label: 'Portrait Process'
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

@Testimonials = new orion.collection 'testimonials',
  singularName: 'testimonial'
  pluralName: 'testimonials'
  title: 'Testimonials'
  link:
    title: 'Testimonials'

  tabular:
    columns: [
      {data: 'quote', title: 'Quote'},
      {data: 'author', title: 'Author'},
    ]


Testimonials.attachSchema new SimpleSchema
  quote:
    type: String
  author:
    type: String

@Portraits = new orion.collection 'portraits',
  singularName: 'portrait'
  pluralName: 'portraits'
  title: 'Portraits'
  link:
    title: 'Gallery'

  tabular:
    columns: [
      {data: 'category', title: 'Category'}
      orion.attributeColumn 'image', 'image', 'Image'
      {data: 'order', title: 'Order'}
    ]

Portraits.attachSchema new SimpleSchema
  category:
    type: String
  image: orion.attribute 'image',
    label: 'Image'

Portraits.attachSchema new SimpleSchema
  order:
    type: Number
    optional: true

# Portrait ordering

Portraits.before.insert (userId, doc) ->
  console.log 'before_doc', doc
  console.log '1', doc
  if not doc.order
    console.log '2', doc
    doc.order = Portraits.find(category: doc.category).count()
    console.log '3', doc
  else
    console.log '4', doc
    if doc.order < 0
      console.log '5', doc
      doc.order = 0
      console.log '6', doc
    if doc.order > Portraits.find(category: doc.category).count()
      console.log '7', doc
      doc.order = Portraits.find(category: doc.category).count()
      console.log '8', doc
    Portraits.find(category: doc.category, order: {$gte : doc.order}).map (portrait) ->
      console.log '9', doc
      Portraits.direct.update {_id: portrait._id}, {$set: {order: portrait.order + 1}}, {validate: false}
      console.log '10', doc
  console.log 'after_doc', doc
  console.log '11', doc
  return doc

Portraits.before.update (userId, doc, fieldNames, modifier, options) ->
  if modifier.$set.order == null
    return modifier

  category = if modifier.$set.category then modifier.$set.category else doc.category
  if modifier.$set.order < 0
    modifier.$set.order = 0
  if modifier.$set.order > Portraits.find(category: category).count() - 1
    modifier.$set.order = Portraits.find(category: category).count() - 1
  if modifier.$set.category != doc.category
    Portraits.find(category: doc.category, order: {$gt : doc.order}).map (portrait) ->
      Portraits.direct.update {_id: portrait._id}, {$set: {order: portrait.order - 1}}, {validate: false}
    Portraits.find(category: modifier.$set.category, order: {$gte : doc.order}).map (portrait) ->
      Portraits.direct.update {_id: portrait._id}, {$set: {order: portrait.order + 1}}, {validate: false}
  else
    Portraits.find(category: category, order: {$gt : doc.order}).map (portrait) ->
      Portraits.direct.update {_id: portrait._id}, {$set: {order: portrait.order - 1}}, {validate: false}
    Portraits.find(category: category, order: {$gte : modifier.$set.order}).map (portrait) ->
      Portraits.direct.update {_id: portrait._id}, {$set: {order: portrait.order + 1}}, {validate: false}
  return modifier

Portraits.before.remove (userId, doc) ->
  Portraits.find(category: doc.category, order: {$gte : doc.order}).map (portrait) ->
    Portraits.direct.update {_id: portrait._id}, {$set: {order: portrait.order - 1}}, {validate: false}


