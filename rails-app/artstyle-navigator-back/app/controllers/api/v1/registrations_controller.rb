module Api
  module V1
    class RegistrationsController < DeviseTokenAuth::RegistrationsController
      def show
        render json: current_api_v1_user
      end

      private

      def sign_up_params
        params.require(:registration).permit(:name, :email, :password, :password_confirmation)
      end
    end
  end
end
