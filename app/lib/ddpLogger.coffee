

Meteor.startup ->
    if Meteor.isClient

      if Meteor.settings and 
        Meteor.settings.public and
        Meteor.settings.public.ddplogLevel > 0
          ddplogLevel = 1
      else
        ddplogLevel = 3

      @lastRoute = "main"

      console.log('dev env, starting ddp logs')
      # log sent messages
      _send = Meteor.connection._send
      Meteor.connection._send = (obj) ->
        if ddplogLevel > 2
          console.log "send", obj
        _send.call this, obj
        return

      # log received messages
      Meteor.connection._stream.on "message", (message) ->
        route = Router.current()
        unless route
          # console.warn("cant find route, using main")
          thisPath = "main"
        else
          thisPath = route.path

        if @lastPath == thisPath
          @pageSize += message.length
        else # new route
          ## reset/init page log
          # console.log("new path", thisPath)
          @lastPath = thisPath
          @pageSize = message.length

        jsonMessage = JSON.parse(message)
        # console.log(jsonMessage)
        window.jsonMessage = jsonMessage
        if (jsonMessage.msg == 'ready')
          Session.set('ddpSize', window.pageSize)
        if ddplogLevel > 2
          console.log("#{thisPath} | #{jsonMessage.msg} | #{jsonMessage.collection or '-'} | #{message.length} | #{window.pageSize} ")
        return







