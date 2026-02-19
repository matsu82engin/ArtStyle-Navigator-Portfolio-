module Api
  module V1
    class SessionsController < DeviseTokenAuth::SessionsController
      include UserSessionizeService
      # 404エラーが発生した場合にヘッダーのみを返す
      rescue_from UserAuth.not_found_exception_class, with: :not_found
      # refresh_tokenのInvalidJitErrorが発生した場合はカスタムエラーを返す
      rescue_from JWT::InvalidJtiError, with: :invalid_jti
      # refresh_tokenのExpiredSignatureが発生した場合はカスタムエラーを返す
      rescue_from JWT::ExpiredSignature, with: :expired_signature_jti
      # 処理前にsessionを削除する
      before_action :delete_session, only: [:create]
      # session_userを取得、存在しない場合は401を返す
      before_action :sessionize_user, only: [:refresh, :destroy]
      # ログアウトしたらリフレッシュトークンを削除する + 認証情報がきちんと確認できたらログアウトする
      before_action :authenticate_api_v1_user!, :destroy_refresh, only: [:destroy]

      # create アクションのオーバーライド
      def create
        super do |resource|
          # サインイン成功時にクッキーにリフレッシュトークンをセット
          if resource.persisted?
            set_refresh_token_to_cookie

            # レスポンスにリフレッシュトークンを含める
            token = resource.create_new_auth_token
            response.headers.merge!(token)
            # ここで必要な追加情報をレスポンスに含める
            # プロフィール情報を取得
            # profile = resource.profile
            # 現時点ではプロフィール情報の中の必要な情報だけレスポンスするようにする
            profile = resource.profile&.slice(:id, :user_id, :pen_name)
            # 全てのプロフィール情報をレスポンスしたいならこちら
            # profile = resource.profile
            render json: {
              # data: resource.as_json,
              data: safe_user_data(resource),
              # data: safe_user_data(resource, profile),
              token: refresh_token,
              expires: refresh_token_expiration,
              # user: @resource.id,
              user: @resource,
              profile:,
              message: 'Login and token refresh successful'
            } and return
          end
        end
      end

      # rubocop:disable Lint/UselessMethodDefinition
      def destroy
        super
      end
      # rubocop:enable Lint/UselessMethodDefinition

      # リフレッシュ
      def refresh
        @resource = session_user

        # DeviseTokenAuthで新しいトークンを生成し、レスポンスヘッダーにセット
        @resource.create_new_auth_token.each do |key, value|
          response.headers[key] = value
        end

        # 新しいリフレッシュトークンを生成し、レスポンスヘッダー + レスポンスにセット
        set_refresh_token_to_cookie
        render json: {
          token: refresh_token,
          expires: refresh_token_expiration,
          user: @resource,
          message: 'access-token refresh!'
        }
      end

      # ログアウト
      def destroy_refresh
        if session_user.nil?
          # 下記コードはデバッグ用
          # Rails.logger.error "Session user is nil. Cannot proceed with logout."
          @resource.forget
          not_found
          return
        end

        # リフレッシュトークンを削除
        if session_user.forget
          delete_session
          cookies[session_key].nil? ? head(:ok) : internal_server_error_response('Could not delete session')
        else
          internal_server_error_response('Could not forget user')
        end
      end

      private

      # refresh_tokenをcookieにセットする
      def set_refresh_token_to_cookie
        cookies[session_key] = {
          value: refresh_token,
          expires: refresh_token_expiration,
          secure: Rails.env.production?,
          same_site: Rails.env.production? ? :none : :lax,
        }
      end

      # リフレッシュトークンのインスタンス生成
      def encode_refresh_token
        # rubocop:disable Naming/MemoizedInstanceVariableName
        @_encode_refresh_token ||= @resource.encode_refresh_token
        # rubocop:enable Naming/MemoizedInstanceVariableName
      end

      # リフレッシュトークン
      def refresh_token
        encode_refresh_token.token
      end

      # リフレッシュトークンの有効期限
      def refresh_token_expiration
        Time.zone.at(encode_refresh_token.payload[:exp])
      end

      # セキュリティ上、必要なデータのみを返すようにする
      def safe_user_data(resource)
        resource.as_json(only: [:id, :uid, :name]) # 不要なデータを除外
      end

      # 404ヘッダーのみの返却を行う
      def not_found
        head(:not_found)
      end

      # リフレッシュアクション用
      # decode jti != user.refresh_jti のエラー処理
      def invalid_jti
        msg = 'Invalid jti for refresh token'
        render status: :unauthorized, json: { status: 401, error: msg }
      end

      def expired_signature_jti
        msg = 'refresh token has expired.'
        render status: :unauthorized, json: { status: 401, error: msg }
      end
    end
  end
end
