require 'chat_sockets'
Rails.application.config.middleware.use ChatHandler
