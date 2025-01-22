module Api
  module V1
    class ProfilesController < ApplicationController
      before_action :authenticate_api_v1_user!
      before_action :authorize_owner!, only: [:update, :destroy]

      def show
        profile = Profile.find(params[:id])
        if profile
          render json: profile
        end
      end

      def create
        if current_api_v1_user.profile.present?
          render json: { error: 'プロフィールはすでに存在します' }, status: :unprocessable_entity
        else
          profile = current_api_v1_user.build_profile(profile_params)
          if profile.save
            render json: profile, status: :created
          else
            render json: { errors: profile.errors.full_messages }, status: :unprocessable_entity
          end
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
        profile = Profile.find(params[:id])

        # 自分のリソースかどうかをチェック
        if profile.user_id != current_api_v1_user.id
          render json: { error: '自分のプロフィールのみ削除可能です' }, status: :forbidden
          return
        end

        if profile.destroy
          render json: { message: 'プロフィールを削除しました' }
        else
          render json: { error: '削除に失敗しました' }, status: :unprocessable_entity
        end
      end

      private

      # ストロングパラメータ。送られてきたパラメータを検閲して指定のパラメータのみ許可
      def profile_params
        params.require(:profile).permit(:pen_name, :art_supply, :introduction)
      end
    end
  end
end
