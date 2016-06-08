Testributor.Pages ||= {}
class Testributor.Pages.TestRuns
  index: ->
    $('[data-toggle="popover"]').popover()

  show: ->
    _.each($("div[id^='error']"), (value, key, list)->
      $(value).html(ansi_up.ansi_to_html($(value).text()))
    )
    $('.show-all-area').on 'click', (e) ->
      if $('#show_all').is(':checked')
        $("div[id^='error']").collapse('show')
        $('.rotate').toggleClass("down")
      else
        $("div[id^='error']").collapse('hide')
        $('.rotate').toggleClass("down")

    $('body').on('click', 'a.disabled', (event) ->
      return false
    )

    $(".js-toggle-collapse").on 'click', (e) ->
      $el = $(e.currentTarget)

      if !$el.hasClass('disabled')
        $el.find('i').toggleClass("down")
