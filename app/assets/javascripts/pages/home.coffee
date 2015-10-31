Testributor.Pages ||= {}
class Testributor.Pages.Home
  index: ->
    $('.navbar-nav a').on 'click', (event) ->
      $anchor = $(@)
      $('html, body').stop().animate({
        scrollTop: $($anchor.attr('href')).offset().top - 0
      }, 1500, 'easeInOutExpo')
      event.preventDefault()
