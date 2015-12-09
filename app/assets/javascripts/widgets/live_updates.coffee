# This widget should be used in any page that need live updates on resources
# resouceId is something like TestRun#1 where 1 is the id of the TestRun.
# callback is the method that will be called with the websocket message as
# an argument.
Testributor.Widgets ||= {}
class Testributor.Widgets.LiveUpdates
  constructor: (resourceId, callback)->
    @resourceId = resourceId
    @callback = callback

    socket = io(Testributor.Config.SOCKETIO_URL)
    socket.on("connect", =>
      # Subscribe to live updates
      $.post(Testributor.Config.LIVE_UPDATES_SUBSCRIBE_URL, {
        uid: socket["id"], resource_id: @resourceId
      }).done((data)->
      )
    )

    socket.on(resourceId, (msg)=>
      @callback(msg)
    )
