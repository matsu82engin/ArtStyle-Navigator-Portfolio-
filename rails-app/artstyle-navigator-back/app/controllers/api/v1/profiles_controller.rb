module Api
  module V1
    class ProfilesController < ApplicationController
      before_action :authenticate_api_v1_user!
      # 最初に、URLから対象のユーザー(@user)を特定する
      before_action :set_user
      # updateとdestroyは、本人しか実行できないように権限チェックを行う
      before_action :authorize_user!, only: [:update, :destroy]

      def show
        profile = @user.profile
        if profile
          render json: profile
        else
          # プロフィールがない場合は、not_foundを返す
          render json: { error: 'Profile not found' }, status: :not_found
        end
      end

      def update
        # set_userとauthorize_user!を通過しているので、
        # @userはログインユーザー本人であることが保証されている。

        # ログインユーザーのプロフィールを取得または新規作成
        profile = @user.profile || @user.build_profile

        if profile.update(profile_params)
          render json: profile, status: :ok
        else
          render json: { errors: profile.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/users/:user_id/profiles
      def destroy
        # set_userとauthorize_user!を通過済み。
        profile = @user.profile

        if profile
          profile.destroy
          head :no_content # 成功時は no_content (204) を返すのが一般的
        else
          render json: { error: 'Profile not found' }, status: :not_found
        end
      end

      private

      def set_user
        # params[:user_id] でユーザーを探す。見つからなければ404を返す。(application_contoroller の rescue_from)
        @user = User.find(params[:user_id])
      end

      def authorize_user!
        # posts_controller と全く同じロジック
        render json: { error: '権限がありません' }, status: :forbidden if params[:user_id].to_s != current_api_v1_user.id.to_s
      end

      # ストロングパラメータ。送られてきたパラメータを検閲して指定のパラメータのみ許可
      def profile_params
        params.require(:profile).permit(:pen_name, :art_supply, :introduction)
      end
    end
  end
end
