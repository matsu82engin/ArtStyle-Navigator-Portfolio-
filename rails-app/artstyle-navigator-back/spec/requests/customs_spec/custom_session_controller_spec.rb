require 'rails_helper'

RSpec.describe 'CustomSessionController', type: :request do
  let(:user) { create(:user) }
  let(:sign_in) { sign_in_user user }

  # 無効なリクエストで返ってくるレスポンスチェック
  def response_check_of_invalid_request(status, error_msg = nil)
    # ステータスコードが期待通りか確認
    expect(response).to have_http_status(status)
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

  # ログアウト
  describe 'DELETE /auth_token (logout)' do
    # before do
    #   sign_in
    #   user.reload
    # end

    context 'with successful logout' do
      it 'logs out and clears the cookie' do
        header = sign_in_user user
        delete destroy_api_v1_user_session_path, headers: header, xhr: true
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
