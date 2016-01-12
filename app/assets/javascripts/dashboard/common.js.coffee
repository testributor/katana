$(document).on 'ready', ->
  # Register Handlebars Helpers
  new Testributor.Helpers.Helper

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
