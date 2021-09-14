Rails.application.routes.draw do
  namespace :api do
    scope :v1 do
      mount_devise_token_auth_for 'User', at: 'auth'
    end

    namespace :v1 do
      resources :conversations, only: [:index, :show]
      resources :messages, only: [:create]
      resources :contacts, only: [:index]
    end
  end
end
