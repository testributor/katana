$(document).on 'ready', ->
  $body = $('body')
  module = $body.data('js-class').split('.')
  method = $body.data('js-method')

  # find namespace
  namespace = _.reduce module.slice(0, -1), ((result, item) ->
    result[item]
  ), Testributor.Pages


  # Execute the corresponding method
  klass = module[0]
  if namespace && namespace.hasOwnProperty(klass)
    page = (new namespace[klass])[method]()

  # Disable all links that have 'disabled' class
  $('a.disabled').click (e) ->
    e.preventDefault()

  # Navbar cookie set
  $('.top-head .navbar-toggle').click ->
    # the code that adds/removes the class from aside element
    # has not been run yet since that code is imported before this code
    # so this event is attached last (so run first)
    $.cookie('left_panel_collapsed', !$('aside.left-panel').hasClass('collapsed'),
      { expires: 1000, path: '/' })
