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

orion.dictionary.addDefinition 'categories', 'site',
  type: String
  label: 'Categories (comma separated)'
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
      {data: 'order', title: 'Order'}
    ]


OilPrices.attachSchema new SimpleSchema
  product:
    type: String
  price:
    type: String
  order:
    type: Number
    optional: true

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
      {data: 'order', title: 'Order'}
    ]


PastelPrices.attachSchema new SimpleSchema
  product:
    type: String
  price:
    type: String
  order:
    type: Number
    optional: true

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
      {data: 'order', title: 'Order'}
    ]


Testimonials.attachSchema new SimpleSchema
  quote:
    type: String
  author:
    type: String
  order:
    type: Number
    optional: true

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
      {data: 'caption', title: 'Caption'}
      {data: 'order', title: 'Order'}
    ]

Portraits.attachSchema new SimpleSchema
  category:
    type: String
  image: orion.attribute 'image',
    label: 'Image'
  caption:
    type: String

Portraits.attachSchema new SimpleSchema
  order:
    type: Number
    optional: true

if Meteor.isServer

  orderBeforeInsert = (collection, userId, doc) ->
    if not doc.order
      doc.order = collection.find({}).count()
    else
      if doc.order < 0
        doc.order = 0
      if doc.order > collection.find({}).count()
        doc.order = collection.find({}).count()
      collection.find(order: {$gte : doc.order}).map (item) ->
        collection.direct.update {_id: item._id}, {$set: {order: item.order + 1}}, {validate: false}
    return doc

  orderBeforeUpdate = (collection, userId, doc, fieldNames, modifier, options) ->
    if modifier.$set.order == null
      return modifier

    if modifier.$set.order < 0
      modifier.$set.order = 0
    if modifier.$set.order > collection.find({}).count() - 1
      modifier.$set.order = collection.find({}).count() - 1
    console.log 'doc', doc
    console.log 'modifier', modifier
    console.log 'collection.find(order: {$gt : doc.order}).fetch()', collection.find(order: {$gt : doc.order}).fetch()
    collection.find(order: {$gt : doc.order}).map (item) ->
      collection.direct.update {_id: item._id}, {$set: {order: item.order - 1}}, {validate: false}
    console.log 'collection.find(order: {$gte : modifier.$set.order}).fetch()', collection.find(order: {$gte : modifier.$set.order}).fetch()
    collection.find(order: {$gte : modifier.$set.order}).map (item) ->
      console.log 'item', item
      collection.direct.update {_id: item._id}, {$set: {order: item.order + 1}}, {validate: false}
    return modifier

  orderBeforeRemove = (collection, userId, doc) ->
    collection.find(order: {$gte : doc.order}).map (item) ->
      collection.direct.update {_id: item._id}, {$set: {order: item.order - 1}}, {validate: false}

  PastelPrices.before.insert (userId, doc) -> orderBeforeInsert PastelPrices, userId, doc
  PastelPrices.before.update (userId, doc, fieldNames, modifier, options) -> orderBeforeUpdate PastelPrices, userId, doc, fieldNames, modifier, options
  PastelPrices.before.remove (userId, doc) -> orderBeforeRemove PastelPrices, userId, doc

  OilPrices.before.insert (userId, doc) -> orderBeforeInsert OilPrices, userId, doc
  OilPrices.before.update (userId, doc, fieldNames, modifier, options) -> orderBeforeUpdate OilPrices, userId, doc, fieldNames, modifier, options
  OilPrices.before.remove (userId, doc) -> orderBeforeRemove OilPrices, userId, doc

  Testimonials.before.insert (userId, doc) -> orderBeforeInsert Testimonials, userId, doc
  Testimonials.before.update (userId, doc, fieldNames, modifier, options) -> orderBeforeUpdate Testimonials, userId, doc, fieldNames, modifier, options
  Testimonials.before.remove (userId, doc) -> orderBeforeRemove Testimonials, userId, doc


  Portraits.before.insert (userId, doc) ->
    if not doc.order
      doc.order = Portraits.find(category: doc.category).count()
    else
      if doc.order < 0
        doc.order = 0
      if doc.order > Portraits.find(category: doc.category).count()
        doc.order = Portraits.find(category: doc.category).count()
      Portraits.find(category: doc.category, order: {$gte : doc.order}).map (portrait) ->
        Portraits.direct.update {_id: portrait._id}, {$set: {order: portrait.order + 1}}, {validate: false}
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


