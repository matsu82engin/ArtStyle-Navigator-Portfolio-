module AuthorizationHelper
  def sign_in_user(user)
    post api_v1_auth_user_session_path, params: { email: user.email, password: user.password }, xhr: true
    # レスポンスのHeadersからトークン認証に必要な要素を抜き出して返す処理
    response.headers.slice('client', 'uid', 'token-type', 'access-token')
  end
end
