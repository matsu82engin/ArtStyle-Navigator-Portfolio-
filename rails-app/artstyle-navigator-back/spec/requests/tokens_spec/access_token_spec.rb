require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  let(:user) { create(:user) }
  let(:header) { sign_in_user(user) }

  before do
    user
    header
  end

  describe 'Access_token' do
    # トークンがきちんと生成されているか
    context 'when authenticates the user' do
      it 'when authenticates the user and returns a token' do
        expect(response).to have_http_status(:ok)
        expect(response.headers['access-token']).to be_present
        expect(response.headers['client']).to be_present
        expect(response.headers['uid']).to eq(user.email)
      end
    end

    context 'with valid token' do
      # トークンがきちんと有効か
      it 'when returns a successful response with valid token' do
        get api_v1_user_path(user.id), headers: header, xhr: true

        expect(response).to have_http_status(:ok)
      end

      # トークンを所持していない状態で認証が必要な場所にアクセスすれば失敗するかどうか
      it 'when you do not have the token fail' do
        get api_v1_user_path(user.id), xhr: true

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with expired token' do
      # トークンの有効期限が切れて認証が必要な場所にアクセスしたら失敗するか
      it 'when denies access with an expired token' do
        travel_to(3.weeks.from_now) do
          get api_v1_user_path(user.id), headers: header, xhr: true
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'when logout the token' do
      # ログアウトしたら headers から情報が消えているか
      it 'when you log out the token is gone' do
        delete destroy_api_v1_auth_user_session_path, headers: header, xhr: true

        expect(response.headers['access-token']).to be_nil
        expect(response.headers['client']).to be_nil
        expect(response.headers['uid']).to be_nil
      end
    end

    context 'with tampered token' do
      it 'with fails authentication with a tampered token' do
        # トークンを改竄
        tampered_header = header.dup
        tampered_header['access-token'] = 'tampered_token'

        get api_v1_user_path(user.id), headers: tampered_header, xhr: true
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
