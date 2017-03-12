require 'faye/websocket'
require 'json/ext'
require 'translator'

module ChatDemo
  class User
		attr_reader :username
		attr_reader :chat_mode
		attr_reader :socket
		def initialize(username, chat_mode, socket)
			@username = username
			@chat_mode = chat_mode
			@socket = socket
		end
  end

  class ChatBackend
    KEEPALIVE_TIME = 15 # in seconds

    def initialize(app)
      @app     = app
      @clients = {}
    end

    def call(env)
			if Faye::WebSocket.websocket?(env)
				ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })

				ws.on :open do |event|
					p [:open, ws.object_id]
				end

				ws.on :message do |event|
					p [:message, event.data]
					command = JSON.parse(event.data)
					p command
					if command["action"] == 'login'
						# Record the newly logged in user
						user = User.new(command["username"], command["chat_mode"], ws)
						@clients[ws.object_id] = user
						# Notify other users about the new user
						@clients.each_key do |client_id|
							@clients[client_id].socket.send({
								"action": "join",
								"username": command["username"],
								"chat_mode": command["chat_mode"]
							}.to_json)
							# Also tell the new user about existing users
							if client_id == ws.object_id
								next # skip telling myself about myself
							end
							ws.send({
								"action": "join",
								"username": @clients[client_id].username,
								"chat_mode": @clients[client_id].chat_mode
							}.to_json)
						end
					elsif command["action"] == 'message'
						translator = Translator.new()
						translated_msg = translator.translate(@clients[ws.object_id].chat_mode, command['message'])
						message = {
							"action": "message",
							"sender" => @clients[ws.object_id].username,
							"msg" => translated_msg
						}.to_json
						@clients.each_key do |client_id|
							client = @clients[client_id]
							client.socket.send(message)
						end
					end
				end

				ws.on :close do |event|
					p [:close, ws.object_id, event.code, event.reason]
					@clients.each_key do |client_id|
						# tell other users that this one quit
						if ws.object_id != client_id 
							@clients[client_id].socket.send({
								"action": "leave",
								"username": @clients[ws.object_id].username
							}.to_json)
						end
					end
					@clients.delete(ws.object_id)
					ws = nil
				end
				ws.rack_response
			else
				@app.call(env)
			end	
    end
  end
end
