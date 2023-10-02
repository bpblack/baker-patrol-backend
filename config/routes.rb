Rails.application.routes.draw do
  scope 'api', constraints: { format: 'json' } do
    post 'user_token', to: 'user_token#create'
    resources :password_resets
    resources :users, only: [:update] do
      resources :seasons, only: [] do
        resources :patrols, only: [:index]              #user patrols for a season
        resources :teams, only: [:index]                #user team for a season
        resources :substitutions, only: [:index]        #user sub history for a season
      end
      resources :substitutions, only: [:index]          #user subs for current season
      member do
        get 'extra'
      end
    end
    resources :patrols, only: [] do
      resources :substitutions, only: [:create]         #create a sub for a given patrol
      member do
        get 'assignable'
        patch 'swap'
      end
    end
    #admin functionality
    scope 'admin' do
      resources :patrols, only: [] do
        resources :substitutions, only: [:index]        #patrol_sub history
      end
      resources :duty_days, only: [] do
        resources :substitutions, path: 'latest_subs', only: [:index]
        member do
          get 'available_patrollers'
        end
      end
      resources :cpr_classes, only: [:index] do
        member do
          patch 'resize'
        end
      end
      resources :students, only: [:index]
    end
    resources :seasons, only: [] do
      resources :duty_days, only: [:index]
      resources :teams, path: 'roster', only: [:index]
      resources :substitutions, path: 'open_requests', only: [:index]
    end
    resources :duty_days, only: [:show]                 #get duty day details
    resources :substitutions, only: [:destroy] do       #delete a sub request
      member do
        patch 'assign'                                  #assign the request to a posted sub id
        patch 'accept'
        patch 'reject'                                  #reject the assigned sub with a posted message
        post  'remind'                                  #create a new reminder email
      end
    end 
    resources :google_calendars, only: [:create] do
      collection do
        get 'authorize'
        delete 'destroy'
        get 'calendars'
        post 'select'
      end
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
  #root to: 'index'
  #get '/*path', to: 'application#index' 
end
