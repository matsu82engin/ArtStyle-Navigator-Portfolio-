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
      # ログアウトしたらリフレッシュトークンを削除する + 認証情報がきちんと確認できたらログアウトする
      before_action :authenticate_api_v1_user!, :destroy_refresh, only: [:destroy]
      # session_userを取得、存在しない場合は401を返す
      before_action :sessionize_user, only: [:refresh]

      # create アクションのオーバーライド
      def create
        super do |resource|
          # サインイン成功時にクッキーにリフレッシュトークンをセット
          set_refresh_token_to_cookie if resource.persisted?
        end
      end

      # リフレッシュ
      def refresh
        @resource = session_user
        set_refresh_token_to_cookie
      end

      # ログアウト
      def destroy_refresh
        if session_user.nil?
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
          http_only: true
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

      # 404ヘッダーのみの返却を行う
      def not_found
        head(:not_found)
      end

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
