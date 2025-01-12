module Api
  module V1
    class ProfilesController < ApplicationController
      before_action :authenticate_api_v1_user!

      def index
      end

    end
  end
end
