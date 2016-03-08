Testributor.Pages ||= {}
class Testributor.Pages.Home
  index: ->

    $('#tour').carousel()

    $('.navbar-nav a').on 'click', (event) ->
      $anchor = $(@)
      $('html, body').stop().animate({
        scrollTop: $($anchor.attr('href')).offset().top - 0
      }, 1500, 'easeInOutExpo')
      event.preventDefault()

    # E-mail form submission
    $("#new_email_submission").on("ajax:complete", (data, status, xhr) ->
      if status.status == 200
        swal("Success!", status.responseText, "success")
      else if status.status == 422 # Unprocessable entity
        swal(status.responseText, "", "error")
      else
        swal(status.statusText, "An error occured. Try again later.", "error")
    )
