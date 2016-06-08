$(document).on 'ready', ->
  $body = $('body')
  module = $body.data('js-class').split('.')
  method = $body.data('js-method')

  # find namespace
  namespace = _.reduce module.slice(0, -1), ((result, item) ->
    result[item]
  ), Testributor.Pages

  # Execute the corresponding method
  klass = module[0]
  if namespace && namespace.hasOwnProperty(klass)
    window.current_page = new namespace[klass]
  if window.current_page && _.isFunction(window.current_page[method])
    window.current_page[method]()
