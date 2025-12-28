require 'rails_helper'

RSpec.describe 'Relationships', type: :request do
  describe 'POST /api/v1/relationships' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:headers) { sign_in_user(user) }

    context 'when follow' do # フォローする
      it 'valid' do # 正常系
        expect do
          post api_v1_relationships_path, params: { followed_id: other_user.id }, headers:, xhr: true
        end.to change(Relationship, :count).by(1)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when cannot follow' do # フォローできない(異常系)
      it 'the user is not authenticated' do # ログインしていないとフォローできない
        post api_v1_relationships_path, params: { followed_id: other_user.id }, xhr: true
        expect(response).to have_http_status(:unauthorized)
      end

      it 'cannot follow myself' do # 自分自身はフォローできない
        post api_v1_relationships_path, params: { followed_id: user.id }, headers:, xhr: true
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'cannot follow the same user multiple times' do # 同じユーザーを複数回フォローできない
        user.follow(other_user)
        post api_v1_relationships_path, params: { followed_id: other_user.id }, headers:, xhr: true
        expect(response).to have_http_status(:conflict)
      end

      it 'cannot floow non-existent users' do # 存在しないユーザーはフォローできない
        post api_v1_relationships_path, params: { followed_id: 99_999 }, headers:, xhr: true
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /api/v1/relationships/:id' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:headers) { sign_in_user(user) }

    context 'when unfollow' do # フォロー解除
      before do
        user.follow(other_user)
      end

      it 'valid' do # 正常系
        expect do
          delete api_v1_relationship_path(other_user.id), headers:, xhr: true
        end.to change(Relationship, :count).by(-1)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when cannot unfollow' do # 異常系
      it 'the user is not authenticated' do # ログインしていないとフォロー解除できない
        delete api_v1_relationship_path(other_user.id), xhr: true
        expect(response).to have_http_status(:unauthorized)
      end

      it 'cannot unfollow users you do not follow' do # フォローしていないユーザーは解除できない
        delete api_v1_relationship_path(other_user.id), headers:, xhr: true
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
