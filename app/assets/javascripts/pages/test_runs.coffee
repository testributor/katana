Testributor.Pages ||= {}
class Testributor.Pages.TestRuns
  show: ->
    jobTemplate = HandlebarsTemplates["test_jobs/test_job"]
    errorTemplate = HandlebarsTemplates["test_jobs/error"]
    testRunId = $('[data-test-run-id]').data('test-run-id')

    Testributor.Widgets.LiveUpdates("TestRun#" + testRunId, (msg)->
      testJob = $.parseJSON(msg).test_job
      $tr = $("#test-job-#{testJob.id}")
      $newTr = $(jobTemplate(testJob))
      $tr.replaceWith($newTr)
      $error = $(errorTemplate(testJob))
      if testJob.show_errors
        $error.insertAfter($newTr)
    )
