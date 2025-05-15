module Api
  module V1
    class RegistrationsController < DeviseTokenAuth::RegistrationsController
      def update
        @resource = current_api_v1_user

        if account_update_params[:password].present? && !@resource.valid_password?(account_update_params[:current_password])
          return render json: { errors: ['現在のパスワードが正しくありません'] }, status: :unprocessable_entity
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
