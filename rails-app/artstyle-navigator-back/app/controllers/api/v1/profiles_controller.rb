module Api
  module V1
    class ProfilesController < ApplicationController
      before_action :authenticate_api_v1_user!

      def show
        # profile = Profile.find(params[:id])
        # profile = Profile.find_by(user_id: params[:id])
        profile = current_api_v1_user.profile
        # render json: profile if profile
        if profile
          render json: profile
        else
          render json: { error: 'Profile not found' }, status: :not_found # プロフィールが見つからない場合の処理
        end
      end

      # def create
      #   if current_api_v1_user.profile.present?
      #     render json: { error: 'プロフィールはすでに存在します' }, status: :unprocessable_entity
      #   else
      #     profile = current_api_v1_user.build_profile(profile_params)
      #     if profile.save
      #       render json: profile, status: :created
      #     else
      #       render json: { errors: profile.errors.full_messages }, status: :unprocessable_entity
      #     end
      #   end
      # end

      def update
        profile = current_api_v1_user.profile || current_api_v1_user.build_profile # 既存プロフィールを取得 or 新規作成

        if profile.update(profile_params) # update で save も兼ねる
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
