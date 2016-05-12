Rails.application.routes.draw do
  get 'custom_claims/index'

  scope 'api' do
    mount Knock::Engine => '/knock' 
    resources :password_resets
    resources :users do
      resources :seasons, only: [] do
        resources :patrols, only: [:index]
        resources :teams, only: [:index]
      end
      resources :custom_claims, only: [:index]
    end
    #admin functionality
    #resources :seasons,only: [] do
    #  resources :teams, only: [:index, :show]
    #end
    resources :duty_days, only: [:index, :show]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
