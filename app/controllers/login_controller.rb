class LoginController < ApplicationController
  def index
    # Clear session
    session[:chat_mode] = nil
    session[:username] = nil
    if params.include?(:login) then
      session[:chat_mode] = params[:login][:mode]
      session[:username] = params[:login][:username]
      redirect_to url_for(:controller => "chat", :action => "index")
    end
  end
end
