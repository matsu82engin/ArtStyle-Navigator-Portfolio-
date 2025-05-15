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

      # rubocop:disable Metrics/PerceivedComplexity
      def update
        # 不正な params[:user_id] をチェック
        if params[:user_id].blank? || params[:user_id] !~ /^\d+$/
          render json: { errors: ['不正なリクエストです'] }, status: :bad_request
          return
        end

        # 現在のユーザーのプロフィールを取得（なければ作成する）
        profile = current_api_v1_user.profile || current_api_v1_user.build_profile

        # URL から取得したプロフィール（他人のプロフィール）を検索
        params_profile = Profile.find_by(user_id: params[:user_id])

        # URL から取得したプロフィールが存在しない場合
        if params_profile.nil?
          # 自分のプロフィールページなら新規作成を許可
          if params[:user_id].to_i == current_api_v1_user.id
            if profile.update(profile_params)
              render json: profile, status: :ok
            else
              render json: { errors: profile.errors.full_messages }, status: :unprocessable_entity
            end
          else
            # 他人のプロフィールページで新規作成はエラー
            render json: { errors: ['プロフィールが見つかりません'] }, status: :not_found
          end
          return
        end

        # 4. 認可処理（他人のプロフィールを更新しようとしていないか）
        unless profile.user_id == paramsProfile.user_id
          render json: { errors: ['権限がありません'] }, status: :forbidden
          return
        end

        # 5. 更新処理
        if profile.update(profile_params)
          render json: profile, status: :ok
        else
          render json: { errors: profile.errors.full_messages }, status: :unprocessable_entity
        end
      end
      # rubocop:enable Metrics/PerceivedComplexity

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
