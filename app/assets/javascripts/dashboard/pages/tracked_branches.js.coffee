Testributor.Pages ||= {}
class Testributor.Pages.TrackedBranches
  new: ->
    $('body').on('ajax:before', 'a#fetch_more', ->
      # Start spinner here
    )
    .on('ajax:success', 'a#fetch_more', (e, data, status, xhr) ->
      new_branches = $(data).find('.list-group').html()
      $(e.currentTarget).replaceWith(new_branches)
      $('[data-toggle="tooltip"]').tooltip()
    )
    .on('ajax:complete', 'a#fetch_more', ->
      # Stop spinner here
    )
