class LoginController < ApplicationController
def index
  if params.include?(:login) then
    @mode = params[:login][:mode]
    @username = params[:login][:username]
    puts "Mode is: #{@mode}"
    return
  end
end
end
