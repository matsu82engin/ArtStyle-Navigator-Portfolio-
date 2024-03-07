require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  describe 'POST /api/v1/auth' do
    context 'with invalid parameters' do
      let(:user) { build(:user) }

      it 'returns a 422 status code' do
        # ファクトリーの user で作られたデータを無効な情報に更新
        user.name = user.email = ''
        user.password = 'foo'
        user.password_confirmation = 'bar'
        post '/api/v1/auth', params: { user: user.attributes }
        expect(response).to have_http_status(422)
      end
    end
  end
end