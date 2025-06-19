Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :show] do
        resource :profiles, only: [:show, :update, :destroy]
      end
      # pictures
      resources :pictures, only: [:index]

      # posts
      resources :posts, only: [:create]

      # devise_token_auth から２つのコントローラを継承してカスタムコントローラを作成
        mount_devise_token_auth_for 'User', at: 'auth', controllers: {
          registrations: "api/v1/registrations",
          sessions: "api/v1/sessions"
        }
        
        devise_scope :api_v1_user do
          post 'sessions/refresh', to: 'sessions#refresh'
        end
    end
  end
end