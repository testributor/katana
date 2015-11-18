Testributor.Pages ||= {}
class Testributor.Pages.ProjectWizard
  update: ->
    $(".multi-select").select2()
  show: ()->
    $(".multi-select").select2()

    $fetchRepos = $('.js-fetch-repos')
    $fetchingRepos = $('.js-fetching-repos')
    currentPath = $fetchRepos.data('current-path')

    if currentPath
      Pace.ignore(->
        jqxhr = $.ajax
          url: currentPath,
          success: ((data, xhr)->
            $fetchRepos.hide()
            $fetchingRepos.hide()
            $fetchRepos.append(data).fadeIn('slow')
          ),
          fail: ((->
            $fetchingRepos.hide()
            alert('Connection with github interrupted!')
            $fetchRepos.append('We were not able to complete this action.').fadeIn('slow')
          )))
