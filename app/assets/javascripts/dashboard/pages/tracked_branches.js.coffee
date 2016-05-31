Testributor.Pages ||= {}
class Testributor.Pages.TrackedBranches
  new: ->
    $('body').on 'ajax:success', '#fetch_more', (e, data, status, xhr) ->
      newBranches = $(data).find('.list-group').html()
      $(e.currentTarget).replaceWith(newBranches)
      $('[data-toggle="tooltip"]').tooltip()
