Testributor.Pages ||= {}
class Testributor.Pages.Settings
  workerSetup: ->
    @technologySelectionInit($('.technology-selections'))

  technologySelectionInit: ($element)->
    return unless $element.length > 0

    $form = $element.find("form")
    $preview = $element.find('#docker-compose-contents')
    $editor = $element.find('#project_custom_docker_compose_yml')
    $submit = $form.find('input[type="submit"]')

    $(".multi-select").select2()

    if $editor.length > 0
      @editor = CodeMirror.fromTextArea($editor[0], {
        mode: {name: 'yaml'},
        lineNumbers: true,
        theme: 'neat',
      })

    if $preview.length > 0
      @preview = CodeMirror.fromTextArea($preview[0], {
        mode: {name: 'yaml'},
        theme: 'neat',
        readOnly: true
      })

    $form.on("ajax:before", (e)=>
      $('.js-ajax-loader').fadeIn(600)
    ).on("ajax:success", (e, data, status, xhr)=>
      @preview.getDoc().setValue(data.alert || data.docker_compose_yml_contents)
    ).on("ajax:complete", (e, elements)=>
      $('.js-ajax-loader').fadeOut(600)
    )

    $('[data-toggle="tooltip"]').tooltip()
