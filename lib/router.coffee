# show = (template, data={}) ->
#   $body = $('body')
#   $body.empty()
#   $body.scrollTop(0)
#   Blaze.renderWithData(template, data, $body[0])

FlowRouter.route '/',
  action: ->
    BlazeLayout.render 'layout1', main: 'home'
    # $('body').empty()
    # Blaze.render Template.home, $('body')[0]
    # $(".fancybox").fancybox()
  # action: -> show Template.home

FlowRouter.route '/gallery/:category',
  action: (params, queryParams) ->
    category = _.unescape(params.category).replace('|||', '/')
    console.log category

if Meteor.isClient
  BlazeLayout.setRoot 'body'
