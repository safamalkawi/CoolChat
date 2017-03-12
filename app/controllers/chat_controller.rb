class ChatController < ApplicationController
	skip_before_action :verify_authenticity_token

  def index
    @current_user = session[:username]
		@chat_mode = session[:chat_mode]

		if @current_user == nil
			redirect_to "/login"
		end
  end
end
