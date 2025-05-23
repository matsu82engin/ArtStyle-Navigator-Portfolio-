require 'rails_helper'

RSpec.describe 'User deleteAccount API', type: :request do
  describe 'delete api_v1_user_registration_path' do # ユーザーの削除
    let(:user) { create(:user) }

    context 'when non-users cannot delete accounts' do # 他のユーザーが違うアカウントを削除しようとすると失敗する
      it 'return a 404 status code' do
        user2 = create(:user)
        headers2 = sign_in_user user2
        delete api_v1_user_registration_path, headers: headers2.merge({ 'uid' => user.email }), xhr: true
        expect(response).to have_http_status(:not_found) # status code 404
      end
    end

    context 'when withdrawn user fails to log in again' do # 退会したユーザーが再度ログインしようとすると失敗すること
      it 'return a 401 status code' do
        headers = sign_in_user user
        delete api_v1_user_registration_path, headers:, xhr: true
        post api_v1_user_session_path, headers:, xhr: true # 退会したらログインできない
        expect(response).to have_http_status(:unauthorized) # この場合はアカウントが存在しないので 401 が返される
        expect(User).not_to exist(user.id) # ユーザーが削除されたか確認
      end
    end

    context 'when a non-existent user is specified' do # 存在しないアカウントに退会リクエストを送る
      it 'return a 404 status code' do
        headers = sign_in_user user
        delete api_v1_user_registration_path, headers:, xhr: true
        # 存在しないアカウントに退会リクエストを送る
        delete api_v1_user_registration_path, headers:, xhr: true
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when token of withdrawn user becomes invalid' do # 退会後に以前のトークンが無効になることを確認する
      it 'return a 401 status code' do
        headers = sign_in_user user
        delete api_v1_user_registration_path, headers:, xhr: true
        # ユーザーが実際に削除されたか確認する。
        expect(User).not_to exist(user.id)
        # 退会後、以前のトークンを使用してアクセスが拒否されることを確認
        get api_v1_user_path(id: user.id), headers:, xhr: true # id を入れる必要がある。
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when deletes the user account' do # ユーザーを削除する
      let(:headers) { sign_in_user(user) } # user でログインして認証情報を取り出す
      let(:profile) { create(:profile, user:) }

      it 'return a 200 status code' do
        delete api_v1_user_registration_path, headers:, xhr: true
        expect(response).to have_http_status(:ok) # status code 200
        expect(User).not_to exist(user.id)
      end

      # 認証されてないリクエスト(ログインせずに退会)が行われた場合、ユーザーアカウントの削除に失敗
      it 'when an unauthenticated request is made fails to delete any user account' do
        delete api_v1_user_registration_path, xhr: true
        expect(response).to have_http_status(:not_found)
      end

      # ユーザーが削除(退会)したとき、プロフィールも削除されている
      it 'when a user deletes, their profile is also deleted' do
        profile
        # Profile の数が１つ減っているかどうかを change(Profile, :count).by(-1) で確認
        expect do
          delete api_v1_user_registration_path, headers:, xhr: true
        end.to change(Profile, :count).by(-1)
        expect(response).to have_http_status(:ok)
        # User モデルにその id を持つレコードが存在しないことを確認
        expect(User).not_to exist(user.id)
      end
    end
  end
end
