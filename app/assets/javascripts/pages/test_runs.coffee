Testributor.Pages ||= {}
class Testributor.Pages.TestRuns
  show: ->
    jobTemplate = """
      <tr id="test-job-<%= id %>" >
        <td><%= command %></td>
        <td class="status">
          <span class="<%= status_css_class %>"><%= status_text %></span>
        </td>
        <td class="errors"><%= test_errors %></td>
        <td class="failures"><%= failures %></td>
        <td class="count"><%= count %></td>
        <td class="assertions"><%= assertions %></td>
        <td class="skips"><%= skips %></td>
        <td class="completed_at"><%= completed_at %></td>
        <td class="running_time">
          <%= total_running_time %>
        </td>
        <td>
          <a class="btn btn-primary btn-xs m-b-5" rel="nofollow" data-method="put" href="<%= retry_url %>"><i class="fa fa-refresh"></i>
          <span>Retry</span>
          </a>
        </td>
      </tr>
    """

    errorTemplate = """
      <tr class=danger>
        <td colspan=10 style='text-align: left;'><%= result %></td>
      </tr>
    """

    compiledErrorTemplate = _.template(errorTemplate)
    compiled = _.template(jobTemplate)
    testRunId = $('[data-test-run-id]').data('test-run-id')
    Testributor.Widgets.LiveUpdates("TestRun#" + testRunId, (msg)->
      testJob = $.parseJSON(msg).test_job
      $tr = $("#test-job-#{testJob.id}")
      $newTr = $(compiled(testJob))
      $tr.replaceWith($newTr)
      $error = $(compiledErrorTemplate(testJob))
      if testJob.show_errors
        $error.insertAfter($newTr)
    )
