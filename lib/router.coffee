# show = (template, data={}) ->
#   $body = $('body')
#   $body.empty()
#   $body.scrollTop(0)
#   Blaze.renderWithData(template, data, $body[0])

FlowRouter.route '/',
  action: ->
    $('body').empty()
    Blaze.render Template.home, $('body')[0]
    $(".fancybox").fancybox()
  # action: -> show Template.home

