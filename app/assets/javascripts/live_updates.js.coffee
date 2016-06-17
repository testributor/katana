class Testributor.LiveUpdates
  initConnection: () ->
    @socket = io(Testributor.Config.SOCKETIO_URL)
    @maxWaitTimeForId = 2000 #ms
    @retryTimesDivider = 5
    setTimeout(=>
      @timeoutReached = true
    , @maxWaitTimeForId)
    $('.js-remote-submission').addClass('disabled')

  socketId: () =>
    return @socket['id'] if @socket && @socket['id']
    @initConnection() if !@socket
    return null

  subscribe: (subscriptions, callback) ->
    if (socketId = @socketId())
      # Subscribe to live updates
      $.post(Testributor.Config.LIVE_UPDATES_SUBSCRIBE_URL, {
        uid: socketId, subscriptions: subscriptions
      }).done((data)->
        $('.disabled.js-remote-submission').removeClass('disabled')
      ).fail((data)->
        document.renderFlash('Connection to server failed. Please try <b>reloading</b> the page.', 'danger')
      )

      @attachSocketEvents(subscriptions, @socket, callback)
    else if !@timeoutReached
      setTimeout(=>
        @subscribe(subscriptions, callback)
      , @maxWaitTimeForId/@retryTimesDivider)
    else
      document.renderFlash('Connection to server failed. Please try <b>reloading</b> the page.', 'danger')

  attachSocketEvents: (subscriptions, socket, callback) ->
    _.each(subscriptions, (entities, resource) =>
      _.each(entities.ids, (id) =>
        socket.on("#{resource}##{id}", callback)
      )
      _.each(entities.actions, (action) =>
        socket.on("Project##{entities.project_id}##{resource}##{action}", callback)
      )
    )
# We need 1 instance of this class in every page
window.liveUpdates = new Testributor.LiveUpdates()
