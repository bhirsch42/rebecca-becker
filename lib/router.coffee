FlowRouter.route '/',
  action: ->
    BlazeLayout.render 'layout1', main: 'home'

FlowRouter.route '/gallery/:category',
  action: (params, queryParams) ->
    BlazeLayout.render 'layout1', main: 'gallery'
    console.log 'flowaction'
    $('.gallery').removeClass('fadeIn')
    setTimeout ->
      masonry()
      setTimeout ->
        $('.gallery').addClass 'fadeIn'
      , 400
    , 400


if Meteor.isClient
  BlazeLayout.setRoot 'body'
