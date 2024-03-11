require 'rails_helper'

RSpec.describe 'User deleteAccount API' do
  describe 'delete api_v1_auth_user_registration_path' do # ユーザーの削除
    before do
      @user = create(:user)
    end

    context 'Non-users cannot delete accounts' do # 他のユーザーがアカウントを削除しようとすると失敗する
      it 'return a 404 status code' do
        user2 = create(:user) 
        headers1 = sign_in @user
        headers2 = sign_in user2
        delete api_v1_auth_user_registration_path, headers: headers2.merge({ 'uid' => @user.email })
        expect(response).to have_http_status(404)
      end
    end

    context 'Withdrawn user fails to log in again' do # 退会したユーザーが再度ログインしようとすると失敗すること
      it 'return a 401 status code' do
        header = sign_in @user
        delete api_v1_auth_user_registration_path, headers: header
        # 退会したらログインできない
        post api_v1_auth_user_session_path, headers: header
        expect(response).to have_http_status(401) # この場合はアカウントが存在しないので 401 が返される
        expect(User.exists?(@user.id)).to be_falsey # ユーザーが削除されたか確認
      end
    end

    context 'when a non-existent user is specified' do # 存在しないアカウントに退会リクエストを送る
      it 'return a 404 status code' do
        header = sign_in @user
        delete api_v1_auth_user_registration_path, headers: header
        # 存在しないアカウントに退会リクエストを送る
        delete api_v1_auth_user_registration_path, headers: header
        expect(response).to have_http_status(404) 
      end
    end

    context 'Token of withdrawn user becomes invalid' do # 退会後に以前のトークンが無効になることを確認する
      it 'return a 401 status code' do
        header = sign_in @user
        delete api_v1_auth_user_registration_path, headers: header
        # ユーザーが実際に削除されたか確認する。
        expect(User.exists?(@user.id)).to be_falsey
        # 退会後、以前のトークンを使用してアクセスが拒否されることを確認
        get api_v1_user_path(id: @user.id), headers: header # id を入れる必要がある。
        expect(response).to have_http_status(401)
      end
    end

    context 'deletes the user account' do # ユーザーを削除する
      it 'return a 200 status code' do
        headers = sign_in @user
        delete api_v1_auth_user_registration_path, headers: headers
        expect(response).to have_http_status(200)
        expect(User.exists?(@user.id)).to be_falsey
      end

      # 認証されてないリクエストが行われた場合、ユーザーアカウントの削除に失敗
      it 'when an unauthenticated request is made fails to delete any user account' do
        delete api_v1_auth_user_registration_path
        expect(response).to have_http_status(404)
      end
    end
  end
end