module Api
  module V1
    class ProfilesController < ApplicationController
      before_action :authenticate_api_v1_user!

      def show
        # users/:user_id/profiles なので user_id に ユーザーオブジェクトの主キー(id)が入っている。よってそれで find をかける。
        user = User.find(params[:user_id])
        # ユーザーに紐づいているプロフィールを便利メソッドから取得
        profile = user.profile
        if profile
          render json: profile
        else
          render json: { error: 'Profile not found' }, status: :not_found
        end
      end

      def update
        profile = current_api_v1_user.profile || current_api_v1_user.build_profile # 既存プロフィールを取得 or 新規作成

        if profile.update(profile_params) # update で save も兼ねる
          render json: profile, status: :ok
        else
          render json: { errors: profile.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        user = User.find(params[:user_id])
        profile = user.profile
        return render json: { error: 'Profile not found' }, status: :not_found unless profile

        if profile.user != current_api_v1_user # 認可処理: プロフィールの所有者と現在のログインユーザーが一致するか
          render json: { error: 'Forbidden' }, status: :forbidden # 403 Forbidden を返す
          return # 一致しなければ処理を中断
        end

        if profile
          profile.destroy
          render json: { message: 'Profile deleted successfully' }, status: :ok
        else
          render json: { error: 'Profile not found' }, status: :not_found # 404 Not Found に修正
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
