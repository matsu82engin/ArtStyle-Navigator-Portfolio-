module Api
  module V1
    class ProfilesController < ApplicationController
      before_action :authenticate_api_v1_user!

      def show
        # ログインしているユーザーのプロフィールを返す
        # profile = Profile.find(params[:id]) # 存在しなければこの時点でエラー。if には進まない
        profile = Profile.find_by(id: (params[:id]))
        if profile
          render json: profile
        else
          # render json: { error: "プロフィールが見つかりません"}, status: :not_found
          render_not_found('プロフィールが見つかりません')
        end
      end

      def create
        profile = current_api_v1_user.build_profile(profile_params)

        if profile.save
          render json: profile, status: :created
        else
          render json: { errors: profile.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        # profile = current_api_v1_user.build_profile(profile_params)
        profile = current_api_v1_user.profile
        if profile.update(profile_params)
          render json: profile, status: :ok
        else
          render json: { errors: profile.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        profile = current_api_v1_user.profile
        # profile = Profile.find_by(id: (params[:id]))
        if profile
          profile.destroy
          head :ok
        else
          render json: { error: "Forbidden"}, status: :forbidden
        end
      end

      private

      def profile_params
        params.require(:profile).permit(:pen_name, :art_supply, :introduction)
      end

    end
  end
end
