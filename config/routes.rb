Rails.application.routes.draw do
  mount Knock::Engine => '/knock'
  resources :password_resets
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
