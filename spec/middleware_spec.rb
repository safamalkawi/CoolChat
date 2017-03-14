require "rails_helper"

require 'chat'

RSpec.describe ChatBackend do
  let (:chatBackend) { ChatBackend.new() }
  it "Should login properly" do
    ws = double()
    allow(ws).to receive(:object_id).and_return(1)
    allow(ws).to receive(:send).and_return(nil)
    chatBackend.commandReceived(ws, '{"action": "login", "username": "safa", "chat_mode": "binary"}')
    expect(chatBackend.clients[ws.object_id].username).to eq('safa')
  end

  it "Should return user already taken" do
    ws = double()
    allow(ws).to receive(:object_id).and_return(1)
    allow(ws).to receive(:send).and_return(nil)
    chatBackend.commandReceived(ws, '{"action": "login", "username": "safa", "chat_mode": "binary"}')


    ws1 = double()
    allow(ws1).to receive(:object_id).and_return(2)
    allow(ws1).to receive(:send).with('{"action":"join","username":"safa","chat_mode":"binary"}')
    allow(ws1).to receive(:send).with('{"action":"logout","message":"username already taken"}')
    chatBackend.commandReceived(ws1, '{"action": "login", "username": "safa", "chat_mode": "binary"}')
  end

  it "Should notify existing users about new user" do
    ws = double()
    allow(ws).to receive(:object_id).and_return(1)
    allow(ws).to receive(:send).with('{"action":"join","username":"safa","chat_mode":"binary"}')
    allow(ws).to receive(:send).with('{"action":"join","username":"safa 2","chat_mode":"binary"}')
    chatBackend.commandReceived(ws, '{"action": "login", "username": "safa", "chat_mode": "binary"}')

    ws1 = double()
    allow(ws1).to receive(:object_id).and_return(2)
    allow(ws1).to receive(:send).with('{"action":"join","username":"safa","chat_mode":"binary"}')
    allow(ws1).to receive(:send).with('{"action":"join","username":"safa 2","chat_mode":"binary"}')
    chatBackend.commandReceived(ws1, '{"action": "login", "username": "safa 2", "chat_mode": "binary"}')
  end

  it "Should send new message to all existing users" do
    ws = double()
    allow(ws).to receive(:object_id).and_return(1)
    allow(ws).to receive(:send).with('{"action":"join","username":"safa","chat_mode":"binary"}')
    allow(ws).to receive(:send).with('{"action":"message","sender":"safa","msg":"10010001100101110110011011001101111 10101111101111111001011011001100100","date":"' + Time.now().to_formatted_s(:time) + '"}')
    chatBackend.commandReceived(ws, '{"action": "login", "username": "safa", "chat_mode": "binary"}')
    chatBackend.commandReceived(ws, '{"action": "message", "message": "Hello World"}')
  end

  it "Should notify existing users about users leaving" do
    ws = double()
    allow(ws).to receive(:object_id).and_return(1)
    allow(ws).to receive(:send).with('{"action":"join","username":"safa","chat_mode":"binary"}')
    allow(ws).to receive(:send).with('{"action":"join","username":"safa 2","chat_mode":"binary"}')
    allow(ws).to receive(:send).with('{"action":"leave","username":"safa 2"}')
    chatBackend.commandReceived(ws, '{"action": "login", "username": "safa", "chat_mode": "binary"}')

    ws1 = double()
    allow(ws1).to receive(:object_id).and_return(2)
    allow(ws1).to receive(:send).with('{"action":"join","username":"safa","chat_mode":"binary"}')
    allow(ws1).to receive(:send).with('{"action":"join","username":"safa 2","chat_mode":"binary"}')
    chatBackend.commandReceived(ws1, '{"action": "login", "username": "safa 2", "chat_mode": "binary"}')
  end
end
