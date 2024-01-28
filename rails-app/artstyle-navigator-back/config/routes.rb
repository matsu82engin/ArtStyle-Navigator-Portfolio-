Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :auth do
        # mount_devise_token_auth_for 'User', at: 'auth' このコードを以下に変更
        mount_devise_token_auth_for 'User', controllers: {
          registrations: "api/v1/registrations"
        }
      end
    end
  end
end
