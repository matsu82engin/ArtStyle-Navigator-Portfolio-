module Api
  module V1
    class ArtStylesController < ApplicationController
      before_action :authenticate_api_v1_user!

      # GET /api/v1/art_styles
      def index
        art_styles = ArtStyle.all
        render json: art_styles.as_json(only: [:id, :name])
      end
    end
  end
end
