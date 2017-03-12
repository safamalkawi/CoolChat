class LoginController < ApplicationController
  def index
    if params.include?(:login) then
      session[:chat_mode] = params[:login][:mode]
      session[:username] = params[:login][:username]
      redirect_to url_for(:controller => "chat", :action => "index")
    end
  end
end
