# Todo これはart_style のファクトリーボットがをきちんと修正できたらやる。

# require 'rails_helper'

# RSpec.describe 'Api::V1::ArtStyles', type: :request do
#   describe 'GET /api/v1/art_styles' do
#     let(:user) { create(:user) }
#     let(:headers) { sign_in_user(user) }
#     context 'when not logged in' do
#       it 'return 401' do
#         get api_v1_art_styles_path(user), xhr: true
#         expect(response).to have_http_status(:unauthorized)
#       end
#     end

#     context 'when you are logged in' do
#       before do
#         create(:art_style)
#       end

#       it 'get a list of artStyles' do
#         get api_v1_art_styles_path(user), headers:, xhr: true
#         expect(response).to have_http_status(:ok)
#         expect(JSON.parse(response.body).first['name']).to eq('リアル系')
#       end
#     end
#   end
# end
