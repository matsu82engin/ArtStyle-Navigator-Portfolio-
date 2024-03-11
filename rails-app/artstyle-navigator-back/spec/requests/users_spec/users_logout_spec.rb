require 'rails_helper'

RSpec.describe 'Logout API', type: :request do
  describe 'delete destroy_api_v1_auth_user_session_path' do
    let(:user) { build(:user) }
    context 'when attempting to log out without being logged in' do # ログインせずにログアウトすると失敗
      it 'returns 404 Not Found' do
        delete destroy_api_v1_auth_user_session_path
        expect(response).to have_http_status(404)
      end
    end

    context 'when logging in and logging out, it succeeds' do # ログインしてログアウトすると成功する
      it 'return a 200 status code ' do
        user = create(:user) 
        headers = sign_in user
        delete destroy_api_v1_auth_user_session_path, headers: headers
        expect(response).to have_http_status(200)
      end
    end

    context 'when deleting token after logging in' do # ログイン後にトークンを削除する
      it 'return a 404 status code' do
        user = create(:user) 
        headers = sign_in user
        headers.delete('access-token')
        delete destroy_api_v1_auth_user_session_path, headers: headers
        expect(response).to have_http_status(404) # 404 なので注意
      end
    end

    context 'when logging out with a different token after logging in' do # ログイン後に違うトークンでログアウトする
      it 'return a 404 status code' do
        user = create(:user) 
        headers = sign_in user
        headers['access-token'] = 'invalid-token' # トークンの変更
        delete destroy_api_v1_auth_user_session_path, headers: headers
        expect(response).to have_http_status(404) 
      end
    end

  end 
end