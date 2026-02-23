Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :show] do
        # フォロー関連ルートの追加
        member do
          get :following
          get :followers
          get :following_state
        end
        
        resource :profiles, only: [:show, :update, :destroy] do
          delete :destroy_avatar, on: :member
        end
        # posts
        resources :posts, only: [:index, :create, :destroy]
      end

      # フォロー関係
      resources :relationships, only: [:create, :destroy]

      # pictures
      resources :pictures, only: [:index]

      # art_styles
      resources :art_styles, only: [:index]

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

  # ヘルスチェック用（追加）
  get '/health', to: proc { [200, {}, [{ status: 'ok' }.to_json]] }
end