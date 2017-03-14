require 'json/ext'
require 'translator'

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
  attr_reader :clients

  def initialize()
    @clients = {}
  end

  def commandReceived(ws, command)
    command = JSON.parse(command)
    if command["action"] == 'login'
      loginUser(ws, command['username'], command['chat_mode'])
    elsif command["action"] == 'message'
      messageReceived(ws, command['message'])
    else
      ws.send({
        "action": "unknown",
        "reason": "unknown command"
      }.to_json)
    end
  end

  def connectionClosed(ws) 
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
  end

  def loginUser(ws, username, chatMode)
    if userExists(username)
      ws.send({
        "action": "logout",
        "message": "username already taken"
      }.to_json)
    end
    # Record the newly logged in user
    user = User.new(username, chatMode, ws)
    @clients[ws.object_id] = user
    # Notify other users about the new user
    @clients.each_key do |client_id|
      @clients[client_id].socket.send({
        "action": "join",
        "username": username,
        "chat_mode": chatMode
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
  end

  def messageReceived(ws, message)
    translator = Translator.new()
    translated_msg = translator.translate(@clients[ws.object_id].chat_mode, message)
    message = {
      "action": "message",
      "sender" => @clients[ws.object_id].username,
      "msg" => translated_msg.strip!,
      "date" => Time.now().to_formatted_s(:time)
    }.to_json
    @clients.each_key do |client_id|
      client = @clients[client_id]
      client.socket.send(message)
    end
  end

  def userExists(username)
    @clients.each_key do |client_id|
      user = @clients[client_id]
      if user.username == username
        return true
      end
    end
    return false
  end

  private :loginUser, :messageReceived, :userExists
end
