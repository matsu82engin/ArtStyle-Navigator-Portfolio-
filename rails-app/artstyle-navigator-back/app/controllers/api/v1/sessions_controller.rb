module Api
  module V1
    class SessionsController < DeviseTokenAuth::SessionsController
      before_action :authenticate_api_v1_user!, only: [:destroy] # rubocop:disable Rails/LexicallyScopedActionFilter
      # create アクションのオーバーライド
      def create
        super do |resource|
          if resource.persisted?
            profile = resource.profile&.slice(:id, :user_id, :pen_name)
            render json: {
              data: safe_user_data(resource),
              user: @resource,
              profile:,
              message: 'Login successful'
            } and return
          end
        end
      end

      private

      def safe_user_data(resource)
        resource.as_json(only: [:id, :uid, :name])
      end
    end
  end
end
