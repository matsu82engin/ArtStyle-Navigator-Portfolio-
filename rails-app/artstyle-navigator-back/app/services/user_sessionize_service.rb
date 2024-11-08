module UserSessionizeService
  # セッションユーザーが居ればtrue、存在しない場合は401を返す
  def sessionize_user
    session_user.present? || unauthorized_user
  end

  # セッションキー
  def session_key
    UserAuth.session_key
  end

  # セッションcookieを削除する
  def delete_session
    cookies.delete(session_key)
  end

  private

  # cookieのtokenを取得(cookie から行っている)
  def token_from_cookies
    cookies[session_key]
  end

  # refresh_tokenから有効なユーザーを取得する
  def fetch_user_from_refresh_token
    User.from_refresh_token(token_from_cookies)
  rescue JWT::InvalidJtiError
    # 下記コードはデバッグ用
    # Rails.logger.debug 'InvalidJtiError detected in fetch_user_from_refresh_token'
    # jtiエラーの場合はcontrollerに処理を委任
    catch_invalid_jti
  rescue JWT::ExpiredSignature
    # リフレッシュトークンの有効期限切れを処理
    handle_expired_token
  rescue UserAuth.not_found_exception_class,
         # デコード、エンコードエラーの時は nil を返す
         JWT::DecodeError, JWT::EncodeError
    #  下記コードはデバッグ用
    #  JWT::DecodeError, JWT::EncodeError => e
    #  Rails.logger.debug "Error detected in fetch_user_from_refresh_token: #{e.message}"
    @resource.forget
    nil
  end

  # refresh_tokenのユーザーを返す
  def session_user
    return nil unless token_from_cookies

    # rubocop:disable Naming/MemoizedInstanceVariableName
    @_session_user ||= fetch_user_from_refresh_token
    # rubocop:enable Naming/MemoizedInstanceVariableName
  end

  # jtiエラーの処理
  def catch_invalid_jti
    delete_session
    # 下記コードはデバッグ用
    # Rails.logger.debug 'catch_invalid_jti method called'
    raise JWT::InvalidJtiError, '無効なJTIです'
  end

  # リフレッシュトークンの有効期限切れの処理
  def handle_expired_token
    delete_session
    raise JWT::ExpiredSignature, 'リフレッシュトークンの有効期限が切れています'
  end

  # 認証エラー
  def unauthorized_user
    delete_session
    head(:unauthorized)
    # 下記コードはデバッグ用
    # Rails.logger.debug 'unauthorized_user method called'
  end
end
