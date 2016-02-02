Testributor.Pages ||= {}
class Testributor.Pages.Settings
  workerSetup: ->
    $(".multi-select").select2()

    $('body').on 'ajax:success', '.js-worker-group-form', (event, data, status, xhr) ->
      $(event.currentTarget).closest('.worker-group').html(data)
    .on 'ajax:error', '.js-worker-group-form', (xhr, status, error) ->
      alert('A error occured on the server!')

    $('body').on 'click', '.js-worker-group-edit-btn', (event) ->
      event.preventDefault()
      $editBtn = $(event.currentTarget)
      $editBtn.closest('.worker-group-info').hide()
      $editBtn.closest('.worker-group').find('.worker-group-form').show()
