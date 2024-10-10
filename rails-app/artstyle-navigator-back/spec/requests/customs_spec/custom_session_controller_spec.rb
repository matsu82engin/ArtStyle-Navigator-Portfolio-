require 'rails_helper'

RSpec.describe 'CustomSessionController', type: :request do
  let(:user) { create(:user) }
  let(:sign_in) { sign_in_user user }
  let(:refresh_lifetime) { UserAuth.refresh_token_lifetime }
  let(:session_key) { UserAuth.session_key.to_s }
  let(:cookie_jar) { request.cookie_jar.instance_variable_get(:@set_cookies) } # インスタンス変数を let に変更

  # tokenのリフレッシュを行うapi
  # def refresh_api
  #   post api_v1_sessions_refresh_path, xhr: true
  # end

  # 無効なリクエストで返ってくるレスポンスチェック
  def response_check_of_invalid_request(status, error_msg = nil)
    # ステータスコードが期待通りか確認
    expect(response).to have_http_status(status)
    # ユーザーの refresh_jti が nil か確認
    user.reload
    expect(user.refresh_jti).to be_nil
    # error_msg が指定されていない場合、レスポンスボディが空か確認
    if error_msg.nil?
      expect(response.body).not_to be_present
    else
      # error_msg が指定されている場合、レスポンスボディに含まれている "error" メッセージを確認
      expect(res_body['error']).to eq(error_msg)
    end
  end

  # 有効なログインのテスト
  describe 'POST /auth_token (login)' do
    context 'with valid login' do
      it 'logs in successfully with valid status and authentication headers' do
        sign_in
        expect(response).to have_http_status(:ok)

        # レスポンスヘッダーからトークンを取得
        access_token = response.headers['access-token']
        uid = response.headers['uid']
        client = response.headers['client']
        expiry = response.headers['expiry']
        user_from_token = User.find_user_by_token(access_token, client, uid)

        # access-token の有効期限の確認 (サーバー時間との差を 3 秒許容)
        expected_expiry = Time.zone.at(expiry.to_i)
        expect(expected_expiry).to be_within(3.seconds).of(DeviseTokenAuth.token_lifespan.from_now)

        # レスポンスの認証情報がログインユーザーと一致するか確認
        expect(user_from_token).to eq(user)
      end

      it 'stores jti in the user record' do
        # jti は保存されているか
        sign_in
        user.reload
        expect(user.refresh_jti).not_to be_nil
      end

      it 'sets the correct cookies with appropriate attributes' do
        sign_in
        refresh_lifetime_to_i = refresh_lifetime.from_now.to_i
        ## cookie
        # cookie のオプションを取得する場合は下記を使用
        # @request.cookie_jar.instance_variable_get(:@set_cookies)[<key>]
        # cookie = @request.cookie_jar.instance_variable_get(:@set_cookies)[session_key]
        cookie = cookie_jar[session_key] # cookie_jar を使用
        # expiresは想定通りか(3秒許容)
        expect(cookie[:expires]).to be_within(3.seconds).of(Time.zone.at(refresh_lifetime_to_i))
        # secureは一致しているか
        expect(cookie[:secure]).to eq(Rails.env.production?)
        # http_onlyはtrueか
        expect(cookie[:http_only]).to be_truthy
      end

      it 'creates a valid refresh token matching the user and expiration' do
        sign_in
        refresh_lifetime_to_i = refresh_lifetime.from_now.to_i
        ## refresh_token
        token_from_cookies = cookies[session_key]
        refresh_token = User.decode_refresh_token(token_from_cookies)
        user.reload
        # ログイン本人と一致しているか
        expect(refresh_token.entity_for_user).to eq(user)
        # jtiは一致しているか
        expect(refresh_token.payload['jti']).to eq(user.refresh_jti)
        # token有効期限とcookie有効期限は一致しているか
        expect(refresh_token.payload['exp']).to eq(refresh_lifetime_to_i)
      end
    end

    # 無効なログイン
    context 'with invalid login' do
      # Ajax通信ではない場合
      it 'returns 403 when not using Ajax' do
        post api_v1_user_session_path, params: { email: user.email, password: user.password }, xhr: false
        response_check_of_invalid_request(403, 'Forbidden')
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  # 有効なリフレッシュ
  # describe 'POST /api/v1/sessions/refresh (token refresh)' do
  #   context 'with valid refresh' do
  #  有効なログイン
  #     it 'refreshes the token successfully' do
  #       sign_in_user user
  #       expect(response).to have_http_status(200)
  #       user.reload
  #       old_access_token = res_body[access_token_key]
  #       old_refresh_token = cookies[session_key]
  #       old_user_jti = user.refresh_jti

  #       post api_v1_sessions_refresh_path, xhr: true
  #       refresh_api
  #       expect(response).to have_http_status(200)
  #       user.reload
  #       new_access_token = res_body[access_token_key]
  #       new_refresh_token = cookies[session_key]
  #       new_user_jti = user.refresh_jti

  #       expect(new_access_token).not_to eq(old_access_token)
  #       expect(new_refresh_token).not_to eq(old_refresh_token)
  #       expect(new_user_jti).not_to eq(old_user_jti)

  #       payload = User.decode_refresh_token(new_refresh_token).payload
  #       expect(payload['jti']).to eq(new_user_jti)
  #     end
  #   end

  # context 'with invalid refresh' do
  #   it 'returns 401 when refresh token is missing' do
  #     refresh_api
  #     response_check_of_invalid_request(401)
  #   end

  #   it 'returns 401 for old refresh token after login in another session' do
  #     login(params)
  #     expect(response).to have_http_status(200)
  #     old_refresh_token = cookies[session_key]

  #     login(params)
  #     expect(response).to have_http_status(200)
  #     new_refresh_token = cookies[session_key]

  #     cookies[session_key] = old_refresh_token
  #     refresh_api
  #     expect(response).to have_http_status(401)
  #     expect(cookies[session_key]).to be_blank
  #     expect(res_body['error']).to eq('Invalid jti for refresh token')

  #     travel_to refresh_lifetime.from_now do
  #     refresh_api
  #     response_check_of_invalid_request(401)
  #    end
  #   end
  #  end

  # ログアウト
  describe 'DELETE /auth_token (logout)' do
    before do
      sign_in
      user.reload
    end

    context 'with successful logout' do
      it 'user jti not nil' do
        # user の jti は nil になっていないか
        expect(response).to have_http_status(:ok)
        expect(user.refresh_jti).not_to be_nil
      end

      it 'sets the cookie' do
        # cookie はきちんと入っているか
        expect(cookie_jar[session_key]).not_to be_nil # cookie_jar を使用
      end

      it 'logs out and clears the cookie' do
        header = sign_in_user user
        delete destroy_api_v1_user_session_path, headers: header, xhr: true
        expect(response).to have_http_status(:ok)
        # ログアウト後クッキーは空になっているか
        expect(cookies[session_key]).to be_blank
        user.reload
        # ログアウト後 jti は nil になっているか
        expect(user.refresh_jti).to be_nil
      end
    end

    context 'when you log out without a session' do
      it 'returns a not found error when session is missing' do
        header = sign_in_user user
        # session がない状態でログアウトしたら401エラーが返ってくるか
        cookies[session_key] = nil
        delete destroy_api_v1_user_session_path, headers: header, xhr: true
        expect(response).to have_http_status(:unauthorized)
        response_check_of_invalid_request(:unauthorized)
      end
    end

    context 'when the cookie expires' do
      it 'returns unauthorized error after refresh token expiration' do
        header = sign_in_user user
        # cookie の有効期限後にログアウトしたらエラー(404)が返ってくるか
        travel_to refresh_lifetime.from_now do
          delete destroy_api_v1_user_session_path, headers: header, xhr: true
          expect(response).to have_http_status(:unauthorized)
          expect(cookies[session_key]).to be_blank
        end

        # travel_back で時間を元に戻す
        travel_back
      end
    end
  end
end
