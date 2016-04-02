Testributor.Pages ||= {}
class Testributor.Pages.TestRuns
  index: ->
    $('[data-toggle="popover"]').popover()

  show: ->
    jobTemplate = HandlebarsTemplates["test_jobs/test_job"]
    errorTemplate = HandlebarsTemplates["test_jobs/error"]
    testRunId = $('[data-test-run-id]').data('test-run-id')
    userIsAdmin = $('[data-admin-user]').data('admin-user')

    progressBar = new Testributor.Widgets.ProgressBar(display_stats: true)
    Testributor.Widgets.LiveUpdates("TestRun#" + testRunId, (msg) ->
      if msg.retry
        progressBar.reset(msg.test_run_id)
      else
        if msg.test_run.terminal_status
          $("#test_run_retry_button").show()

        testJob = $.extend(msg.test_job, admin: userIsAdmin)
        $("#test-job-#{testJob.id}").fadeOut('slow', () ->
           $("#test-job-#{testJob.id}").replaceWith $(jobTemplate(testJob))
           $(jobTemplate(testJob)).fadeIn('slow')
        )


        $error = $(errorTemplate(testJob))
        if testJob.unsuccessful
          $error.insertAfter($(jobTemplate(testJob)))
        progressBar.update(testJob.test_run_id, testJob.html_class)
    )
    $('[data-toggle="popover"]').popover()


    _.each($("div[id^='error']"), (value, key, list)->
      $(value).html(ansi_up.ansi_to_html($(value).text()))
    )
    #show all button
    $('.show-all-area').on 'click', (e) ->
      if $('#show_all').is(':checked')
        $("div[id^='error']").collapse('show')
      else
        $("div[id^='error']").collapse('hide')
