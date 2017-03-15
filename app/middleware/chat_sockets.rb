require 'faye/websocket'

require 'chat'

class ChatHandler
  KEEPALIVE_TIME = 15 # in seconds

  def initialize(app)
    @app     = app
    @backend = ChatBackend.new()
  end

  def call(env)
    if Faye::WebSocket.websocket?(env)
      ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })

      ws.on :open do |event|
        p [:open, ws.object_id]
      end

      ws.on :message do |event|
        p [:message, event.data]
        @backend.commandReceived(ws, event.data)
      end

      ws.on :close do |event|
        p [:close, ws.object_id, event.code, event.reason]
        @backend.connectionClosed(ws)
      end
      ws.rack_response
    else
      @app.call(env)
    end	
  end
end
