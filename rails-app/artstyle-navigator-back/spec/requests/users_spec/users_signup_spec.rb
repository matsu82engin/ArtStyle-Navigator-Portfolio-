require 'rails_helper'

RSpec.describe 'Signup API', type: :request do
  describe 'POST api_v1_auth_user_registration_path' do
    context 'when signing up with invalid parameters' do # User API が失敗のステータスコードを返すかテスト
      it 'signup returns a 422 status code' do
        # ファクトリーの user で作られたデータを使って無効な情報を POST
        user_params = { name: '', email: '', password: 'foo', password_confirmation: 'bar' } 
        # 無効な情報を送信できているか確認
        # puts user_params.inspect
        post api_v1_auth_user_registration_path, params: user_params
        # API から無効なレスポンスが返ってくる
        expect(response).to have_http_status(422)
      end
    end

    context 'when signing up with valid parameters' do # User API が成功のステータスコードを返すかテスト
      let(:user) { build(:user) }
      it 'signup returns a 200 status code' do
        post api_v1_auth_user_registration_path, params: { name: user.name, email: user.email, password: user.password, password_confirmation: user.password_confirmation } 
        # API から有効なレスポンスが返ってくる
        expect(response).to have_http_status(200)
      end
    end
  end
end