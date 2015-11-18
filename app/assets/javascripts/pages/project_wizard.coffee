Testributor.Pages ||= {}
class Testributor.Pages.ProjectWizard
  update: ->
    $(".multi-select").select2()
  show: ()->
    $(".multi-select").select2()

    $fetchRepos = $('.js-fetch-repos')
    $fetchingRepos = $('.js-fetching-repos')
    currentPath = $fetchRepos.data('current-path')

    if $fetchRepos
      Pace.ignore ->
        jqxhr = $.ajax
          url: currentPath,
          success: (data)->
            $fetchRepos.append(data).fadeIn('slow')
          fail: ->
            alert('Connection with github interrupted!')
            $fetchRepos.append('We were not able to complete this action.').fadeIn('slow')
          error: ->
            $fetchRepos.append('Oops! Something went wrong. We are working on it.').fadeIn('slow')
          complete: ->
            $fetchingRepos.hide()

