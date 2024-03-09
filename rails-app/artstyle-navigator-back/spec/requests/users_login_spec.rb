require 'rails_helper'

RSpec.describe 'Login API', type: :request do
  describe 'POST api_v1_auth_user_session_path' do
    context 'with invalid parameters login' do # ログインの失敗のステータスコード 
      it 'login return a 401 status code' do
        user_params = { email: '', password: ''}
        # 無効な情報を送信できているか確認 puts user_params.inspect
        post api_v1_auth_user_session_path, params: user_params
        # API から無効なレスポンスが返ってくる
        expect(response).to have_http_status(401)
      end
    end

    context 'with valid parameters login' do # ログイン成功のステータスコード
      let(:user) { build(:user) }
      it 'login return a 200 status code' do
        # ログインするには登録する必要がある
        post api_v1_auth_user_registration_path, params: { name: user.name, email: user.email, password: user.password, password_confirmation: user.password_confirmation } 
        # email, password を パラメータに入れる
        user_params = { email: user.email, password: user.password }
        # 登録した情報でログイン
        post api_v1_auth_user_session_path, params: user_params
        expect(response).to have_http_status(200)
      end
    end
  end
end