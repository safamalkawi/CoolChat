Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
get '/login', to: 'login#index'
post '/login/index'

get '/chat', to: 'chat#index'

end
