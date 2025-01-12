require 'rails_helper'

RSpec.describe 'Profiles', type: :request do
  let(:user) { create(:user) } # FactoryBotでuserを作成
  let(:headers) { sign_in_user(user) }

  describe 'GET /index' do
    context 'プロフィールが存在している場合' do
      let!(:profile) { create(:profile)}

      it 'ステータスコード200 を返す' do
        get api_v1_profiles_path, headers: headers, xhr: true
        expect(response).to have_http_status(200)
      end

    end
  end
end
