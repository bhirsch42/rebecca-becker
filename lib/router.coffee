FlowRouter.route '/',
  action: ->
    BlazeLayout.render 'layout1', main: 'home'

FlowRouter.route '/gallery/:category',
  action: (params, queryParams) ->
    BlazeLayout.render 'layout1', main: 'gallery'


if Meteor.isClient
  BlazeLayout.setRoot 'body'
