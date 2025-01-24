require 'rails_helper'

RSpec.describe 'Profiles', type: :request do
  let(:user) { create(:user) } # FactoryBot で user を作成
  let(:headers) { sign_in_user(user) } # user でログインして認証情報を取り出す

  describe 'GET /profiles/:id' do
    let(:profile) { create(:profile, user:) }

    context 'when the user is authenticated' do # 認証済みユーザーの場合
      it 'retrieves the user profile successfully' do # 特定のユーザーのプロフィール情報を取得できる
        get api_v1_profile_path(profile), headers:, xhr: true
        expect(response).to have_http_status(:ok)
      end

      it 'has expected profile attributes' do # 特定のユーザーのプロフィールには想定通りのカラムがある
        get api_v1_profile_path(profile), headers:, xhr: true
        json_response = res_body
        %w[user_id pen_name art_style_id art_supply introduction].each do |key|
          expect(json_response[key]).to eq(profile.send(key))
        end
      end

      it 'returns an error when profile ID does not exist' do # 存在しないユーザーIDで取得しようとした際にエラーが返る
        get api_v1_profile_path(99_999), headers:, xhr: true
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the user is not authenticated' do # 認証されていないユーザーの場合
      it 'cannot retrieve profile information' do # プロフィール情報を取得できない
        get api_v1_profile_path(profile.id), xhr: true
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /profiles' do
    # let(:profile) { create(:profile, user: user) }
    let(:valid_params) do
      {
        profile: {
          pen_name: 'New Pen Name',
          art_supply: 'デジタルペン : ペンタブレット(ペンタブ)',
          introduction: '新しい自己紹介文です。'
        }
      }
    end

    context 'when a logged-in user submits valid parameters' do # ログインユーザーが正しいパラメータを送信したらプロフィールが作成されるか
      it 'create your profile' do # プロフィールを作成
        post api_v1_profiles_path, params: valid_params, headers:, xhr: true
        expect(response).to have_http_status(:created)
        # きちんとプロフィールが作成されているデータの中身を確認する
        # created_profile = Profile.find(profile.id)
        # created_profile = user.reload.profile
        created_profile = user.profile # valid_params で作成したプロフィールを取得
        expect(created_profile.pen_name).to eq('New Pen Name')
        expect(created_profile.art_supply).to eq('デジタルペン : ペンタブレット(ペンタブ)')
        expect(created_profile.introduction).to eq('新しい自己紹介文です。')
      end
    end

    context 'when logged-in user already has a profile' do # ログインユーザーが既にプロフィールが作成している場合
      before do
        create(:profile, user:) # 事前にプロフィールを作成
      end

      it 'You cannot create a new profile' do # 新しいプロフィールは作成できない
        post api_v1_profiles_path, params: valid_params, headers:, xhr: true
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when a logged-in user sends an invalid parameter' do # ログインユーザーが不正なパラメータを送信した時
      let(:invalid_params) do
        {
          profile: {
            pen_name: '   ', # 空白のみは無効
            art_supply: '', # 選択肢以外の値は無効(空白, nilも)
            introduction: '   ' # 空白のみは無効
          }
        }
      end

      it 'profile cannot be created with invalid parameters' do # 不正なパラメータを送信したらプロフィールが作成できない
        post api_v1_profiles_path, params: invalid_params, headers:, xhr: true
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = res_body
        expect(json_response['errors']).to include("Pen name can't be blank")
        expect(json_response['errors']).to include('Art supply is not included in the list')
        expect(json_response['errors']).to include("Introduction can't be blank")
      end

      it 'unauthenticated user sends a creation request' do # 未認証のユーザーが作成リクエストを送った場合
        post api_v1_profiles_path, params: invalid_params, xhr: true
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /profiles/:id' do
    context 'when update your profile' do # プロフィールの更新
      let(:profile) { create(:profile, user:) }

      let(:valid_params) do
        {
          profile: {
            pen_name: 'Updated Pen Name',
            art_supply: 'デジタルペン : 液晶タブレット(液タブ)',
            introduction: '更新された自己紹介文です。'
          }
        }
      end

      let(:invalid_params) do
        {
          profile: {
            pen_name: '',
            art_supply: '',
            introduction: ''
          }
        }
      end

      it 'logged in user submits correct parameters' do # ログインユーザーが正しいパラメータを送信するとプロフィールが更新されるか
        patch api_v1_profile_path(profile), params: valid_params, headers:, xhr: true # profiles ではなく profile
        expect(response).to have_http_status(:ok)
        json_response = res_body
        # 送信した正しいパラメータが含まれているか
        expect(json_response['pen_name']).to include('Updated Pen Name')
        expect(json_response['art_supply']).to include('デジタルペン : 液晶タブレット(液タブ)')
        expect(json_response['introduction']).to include('更新された自己紹介文です。')
      end

      it 'update with invalid parameters' do # 不正なパラメータで更新しようとした場合、エラーが返る
        patch api_v1_profile_path(profile), params: invalid_params, headers:, xhr: true
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = res_body
        # 不正なパラメータなのでエラーが返ってきているか
        expect(json_response['errors']).to be_present
      end

      it 'update by unauthorized user' do # 権限がないユーザーが更新しようとした場合、エラーが返る
        patch api_v1_profile_path(profile), params: valid_params, xhr: true
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /profiles/:id' do
    let!(:profile) { create(:profile, user:) } # user のプロフィールを作成して関連づける
    let!(:user2) { create(:user) } # 別のユーザーを作成
    let(:profile2) { create(:profile, user: user2) } # 別のユーザーが別のプロフィールを作成

    context 'when destroy profile' do # プロフィールの削除
      it 'delete my profile' do # 自分のプロフィールを削除できるか
        # expect do
        #   delete api_v1_profile_path(profile), headers:, xhr: true
        # end.to change { Profile.count }.by(-1)
        expect { delete api_v1_profile_path(profile), headers:, xhr: true }
          .to change(Profile, :count).by(-1)
        expect(response).to have_http_status(:ok)
        get api_v1_profile_path(profile), headers:, xhr: true
        expect(response).to have_http_status(:not_found)
      end

      it 'error when trying to delete someone else profile' do # 他人のプロフィールを削除しようとすると403エラーが返るか
        delete api_v1_profile_path(profile2.id), headers:, xhr: true
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
