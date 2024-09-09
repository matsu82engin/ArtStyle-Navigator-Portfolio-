Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :show]
      resources :sessions, only: [:create] do
        post :refresh, on: :collection 
      end

      namespace :auth do
        mount_devise_token_auth_for 'User', controllers: {
          registrations: "api/v1/registrations",
          sessions: "api/v1/sessions"
        }
      end
    end
  end
end
