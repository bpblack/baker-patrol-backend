Rails.application.routes.draw do
  get 'custom_claims/index'                             #TODO: delete

  scope 'api' do
    post 'user_token' => 'user_token#create'
    resources :password_resets
    resources :users do
      resources :seasons, only: [] do
        resources :patrols, only: [:index]              #user patrols for a season
        resources :teams, only: [:index]                #user team for a season
        resources :substitutions, only: [:index]        #user sub history for a season
      end
      resources :custom_claims, only: [:index]          #TODO: delete
      resources :substitutions, only: [:index]          #user subs for current season
    end
    resources :patrols, only: [] do
      resources :substitutions, only: [:create]         #create a sub for a given patrol
    end
    #admin functionality
    scope 'admin' do
      resources :patrols, only: [] do
        resources :substitutions, only: [:index]        #patrol_sub history
      end
      #resources :seasons,only: [] do
      #  resources :teams, only: [:index, :show]
      #end
    end
    resources :duty_days, only: [:index, :show]         #list duty days and get duty day details
    resources :substitutions, only: [:destroy] do       #delete a sub request
      member do
        patch 'assign'                                  #assign the request to a posted sub id
        patch 'accept'
        patch 'reject'                                  #reject the assigned sub with a posted message
        post  'remind'                                  #create a new reminder email
      end
    end 
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
