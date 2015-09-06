# Execute js code both on document ready and page:load.
# 'page:load' is a turbolinks event which is executed
# when page is changed. Due to the fact that the 'ready' event
# is not triggered when page is changed,
# we have to listen to the 'page:load' event as well,
# so that the following code is executed.
$(document).on 'ready page:load', ->
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
    page = (new namespace[klass])[method]()
