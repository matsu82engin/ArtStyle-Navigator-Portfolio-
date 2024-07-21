require 'rails_helper'

RSpec.describe 'Logout API', type: :request do
  describe 'delete destroy_api_v1_auth_user_session_path' do
    let(:user) { build(:user) }

    context 'when attempting to log out without being logged in' do # ログインせずにログアウトすると失敗
      it 'returns 404 Not Found' do
        delete destroy_api_v1_auth_user_session_path
        expect(response).to have_http_status(:not_found) # 404
      end
    end

    context 'when logging in and logging out, it succeeds' do # ログインしてログアウトすると成功する
      it 'return a 200 status code' do
        user = create(:user)
        header = sign_in_user user
        delete destroy_api_v1_auth_user_session_path, headers: header
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when deleting token after logging in' do # ログイン後にトークンを削除する
      it 'return a 404 status code' do
        user = create(:user)
        header = sign_in_user user
        header.delete('access-token')
        delete destroy_api_v1_auth_user_session_path, headers: header
        expect(response).to have_http_status(:not_found) # 404 なので注意
      end
    end

    context 'when logging out with a different token after logging in' do # ログイン後に違うトークンでログアウトする
      it 'return a 404 status code' do
        user = create(:user)
        header = sign_in_user user
        header['access-token'] = 'invalid-token' # トークンの変更
        delete destroy_api_v1_auth_user_session_path, headers: header
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
