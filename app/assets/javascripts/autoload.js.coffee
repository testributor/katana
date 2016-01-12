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
    page = new namespace[klass]
  if page && _.isFunction(page[method])
    page[method]()
