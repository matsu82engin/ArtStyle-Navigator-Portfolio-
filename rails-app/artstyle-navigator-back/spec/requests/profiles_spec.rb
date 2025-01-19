require 'rails_helper'

RSpec.describe 'Profiles', type: :request do
  let(:user) { create(:user) } # FactoryBot で user を作成
  # let(:profile) { create(:profile, user: user) } # FactoryBotで profile を作成
  let(:headers) { sign_in_user(user) } # user でログインして認証情報を取り出す

  describe 'GET /profiles/:id' do
    let(:profile) { create(:profile, user: user) }
    context '認証済みユーザーの場合' do
      it '特定のユーザーのプロフィール情報を取得できる' do
        get api_v1_profile_path(profile), headers: headers, xhr: true
        expect(response).to have_http_status(:ok)
      end

      it '特定のユーザーのプロフィールには想定通りのカラムがある' do
        get api_v1_profile_path(profile), headers: headers, xhr: true
        json_response = res_body
        # expect(json_response['user_id']).to eq(profile.user_id)
        # expect(json_response['pen_name']).to eq(profile.pen_name)
        # expect(json_response['art_style_id']).to eq(profile.art_style_id)
        # expect(json_response['art_supply']).to eq(profile.art_supply)
        # expect(json_response['introduction']).to eq(profile.introduction)

        # こっちでもいい
        # expect(json_response).to include(
        #   'user_id' => profile.user_id,
        #   'pen_name' => profile.pen_name,
        #   'art_style_id' => profile.art_style_id
        # )

        %w[user_id pen_name art_style_id art_supply introduction].each do |key|
          expect(json_response[key]).to eq(profile.send(key))
        end
      end

      it '存在しないユーザーIDで取得しようとした際にエラーが返る' do
        get api_v1_profile_path(99999), headers: headers, xhr: true
        expect(response).to have_http_status(404)
      end
    end

    context '認証されていないユーザーの場合' do
      it 'プロフィール情報を取得できない' do
         get api_v1_profile_path(profile.id), xhr: true
         expect(response).to have_http_status(401)
      end
    end
  end

  describe 'POST /profiles' do
    let(:profile) { create(:profile, user: user) }
    context 'ログインユーザーが正しいパラメータを送信したらプロフィールが作成されるか' do

      let(:valid_params) do
        {
          profile: {
            pen_name: 'New Pen Name',
            art_supply: 'デジタルペン : ペンタブレット(ペンタブ)',
            introduction: '新しい自己紹介文です。'
          }
        }
      end

      it 'プロフィールを作成' do
        post api_v1_profiles_path, params: valid_params, headers: headers, xhr: true
        expect(response).to have_http_status(:created)
        # きちんとプロフィールが作成されているデータの中身を確認する
        # created_profile = Profile.find(profile.id)
        # created_profile = user.reload.profile
        created_profile = user.profile # valid_params で作成したプロフィールを取得
        expect(created_profile.pen_name).to eq('New Pen Name')
        expect(created_profile.art_supply).to eq('デジタルペン : ペンタブレット(ペンタブ)')
        expect(created_profile.introduction).to eq('新しい自己紹介文です。')
      end

      it '新しいプロフィールは作成できない' do
        # 保留
        # post api_v1_profiles_path, params: valid_params, headers: headers, xhr: true
        # expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'ログインユーザーが不正なパラメータを送信したらエラーが返るか' do

      let(:invalid_params) do
        {
          profile: {
            pen_name: '   ',  # 空白のみは無効
            art_supply: '', # 選択肢以外の値は無効(空白, nilも)
            introduction: '   ' # 空白のみは無効
          }
        }
      end

      it '不正なパラメータを送信したらプロフィールが作成できない' do
        post api_v1_profiles_path, params: invalid_params, headers: headers, xhr: true
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = res_body
        expect(json_response['errors']).to include("Pen name can't be blank")
        expect(json_response['errors']).to include("Art supply is not included in the list")
        expect(json_response['errors']).to include("Introduction can't be blank")
      end

      it '未認証のユーザーが作成リクエストを送った場合' do
        post api_v1_profiles_path, params: invalid_params, xhr: true
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /profiles/:id' do
    context 'プロフィールの更新' do
      let(:profile) { create(:profile, user: user) }

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

      it 'ログインユーザーが正しいパラメータを送信するとプロフィールが更新されるか' do
        patch api_v1_profile_path(profile), params: valid_params, headers: headers, xhr: true # profiles ではなく profile
          expect(response).to have_http_status(:ok)
          json_response = res_body
          # 送信した正しいパラメータが含まれているか
          expect(json_response['pen_name']).to include('Updated Pen Name')
          expect(json_response['art_supply']).to include('デジタルペン : 液晶タブレット(液タブ)')
          expect(json_response['introduction']).to include('更新された自己紹介文です。')
      end

      it '不正なパラメータで更新しようとした場合、エラーが返る' do
        patch api_v1_profile_path(profile), params: invalid_params, headers: headers, xhr: true
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = res_body
        # 不正なパラメータなのでエラーが返ってきているか
        expect(json_response['errors']).to be_present
      end

      it '権限がないユーザーが更新しようとした場合、エラーが返る' do
        patch api_v1_profile_path(profile), params: valid_params, xhr: true
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /profiles/:id' do
    let!(:profile) { create(:profile, user: user) } # user のプロフィールを作成して関連づける
    let!(:user2) { create(:user) } # 別のユーザーを作成
    let(:profile2) { create(:profile, user: user2)} # 別のユーザーが別のプロフィールを作成

    context 'プロフィールの削除' do
      it '自分のプロフィールを削除できるか' do
        expect {
        delete api_v1_profile_path(profile), headers:headers, xhr: true
      }.to change{ Profile.count}.by(-1)
        expect(response).to have_http_status(:ok)
        get api_v1_profile_path(profile), headers: headers, xhr: true
        expect(response).to have_http_status(:not_found)
      end

      it '他人のプロフィールを削除しようとすると403エラーが返るか' do
        # このテストはエラー！！認可ができてない
        delete api_v1_profile_path(profile2.id), headers:headers, xhr: true
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

end
