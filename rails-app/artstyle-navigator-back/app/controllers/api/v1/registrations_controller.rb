module Api
  module V1
    class RegistrationsController < DeviseTokenAuth::RegistrationsController

    def update
      @resource = current_api_v1_user

      # パスワードを変更しようとしている時のみ、現在のパスワード確認
      if account_update_params[:password].present?
        unless @resource.valid_password?(account_update_params[:current_password])
          return render json: { errors: ['現在のパスワードが正しくありません'] }, status: :unauthorized
        end
      end

      # その後 update 処理続行
      super
    end

      private

      def account_update_params
        params.permit(:name, :email, :password, :password_confirmation, :current_password)
      end
    end
  end
end
