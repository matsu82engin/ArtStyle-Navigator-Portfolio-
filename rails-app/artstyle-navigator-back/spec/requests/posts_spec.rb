require 'rails_helper'

RSpec.describe 'Posts API', type: :request do
  describe 'POST /api/v1/posts' do
    let!(:user) { create(:user) } # 投稿するユーザー (認証が必要ならトークンなども準備)
    let(:headers) { sign_in_user(user) } # user でログインして認証情報を取り出す
    let!(:art_style) { ArtStyle.find_by!(name: 'リアル系') } # 作成済みのマスターデータを "見つけてくる"

    let(:base_attributes) do # ベースの属性 (PostImage の部分は正常)
      {
        post: {
          title: 'Valid Title',
          post_images_attributes: {
            '0' => { art_style_id: art_style.id, position: 0, image: sample_image_file, caption: 'Image 1' },
            '1' => { art_style_id: art_style.id, position: 1, image: sample_image_file, caption: 'Image 2' }
          }
        }
      }
    end

    context 'with valid parameters' do # 有効なパラメータ
      let(:valid_attributes) do
        {
          post: {
            title: '新しい投稿のタイトル',
            post_images_attributes: {
              '0' => {
                art_style_id: art_style.id,
                position: 0,
                caption: '最初の画像の説明',
                image: sample_image_file,
                tips: '描画のコツ1',
                alt: '画像1'
              },
              '1' => {
                art_style_id: art_style.id,
                position: 1,
                caption: '二番目の画像の説明',
                image: sample_image_file,
                tips: '描画のコツ2',
                alt: '画像2'
              }
            }
          }
        }
      end

      it 'creates a new Post and associated PostImages' do # 新しい投稿と関連する投稿画像を作成
        expect do
          post api_v1_user_posts_path(user), params: valid_attributes, headers:, xhr: true
        end.to change(Post, :count).by(1).and(
          change(PostImage, :count).by(2) # PostImageが2つ作成されることを期待
        )
        # リクエスト後の処理
        created_post = Post.last # 作成されたPostを取得
        expect(created_post.post_images.count).to eq(2) # Postに紐づくPostImageが2つあるか
        created_post.post_images.each do |post_image|
          expect(post_image.post_id).to eq(created_post.id) # 各PostImageのpost_idが親Postのidと一致するか
        end
      end

      it 'returns a created status' do
        post api_v1_user_posts_path(user), params: valid_attributes, headers:, xhr: true
        expect(response).to have_http_status(:created)
      end

      it 'returns the created post and post_images in JSON' do # 作成された投稿と post_images を JSON で返す。
        post api_v1_user_posts_path(user), params: valid_attributes, headers:, xhr: true
        # json_response = JSON.parse(response.body)
        json_response = response.parsed_body

        expect(json_response['post']['title']).to eq('新しい投稿のタイトル')
        expect(json_response['post_images'].count).to eq(2)
        expect(json_response['post_images'][0]['caption']).to eq('最初の画像の説明')
        expect(json_response['post_images'][1]['position']).to eq(1)
      end
    end

    # ここから無効なパラメータのテスト
    context 'with invalid title' do # 無効なタイトルパラメータ
      it 'cannot post when user is not authenticated' do # 認証されてないユーザーの投稿
        post api_v1_user_posts_path(user), params: base_attributes, xhr: true
        expect(response).to have_http_status(:unauthorized)
      end

      it 'no title returns 422' do # タイトルを入れない場合はエラー
        params_with_nil_title = base_attributes.deep_merge(post: { title: nil })
        post api_v1_user_posts_path(user), params: params_with_nil_title, headers:, xhr: true
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'title length 51 is returns 422' do # タイトルが 51 文字ならエラー
        params_with_long_title = base_attributes.deep_merge(post: { title: 'a' * 51 })
        post api_v1_user_posts_path(user), params: params_with_long_title, headers:, xhr: true
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when invalid post_images_attributes' do # (画像1枚以上必須)
      it 'returns 422 if post_images_attributes is empty' do # 画像がなければエラー
        params_with_empty_images = base_attributes.merge(
          post: {
            post_images_attributes: {
              '0' => { art_style_id: art_style.id, position: 0, image: nil }
            }
          }
        )
        post api_v1_user_posts_path(user), params: params_with_empty_images, headers:, xhr: true
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when root :post key is missing' do # post: でラップされていない場合
      let(:params_missing_root_key) do
        {
          title: 'Title without root key',
          post_images_attributes: {
            '0' => { art_style_id: art_style.id, position: 0, image: sample_image_file }
          }
        }
      end

      it 'returns 400 Bad Request when :post key is missing from params' do # :post キーがなければエラー
        post api_v1_user_posts_path(user), params: params_missing_root_key, headers:, xhr: true
        expect(response).to have_http_status(:bad_request) # 要 rescue_from
      end
    end

    context 'when a post_image' do # 絵柄について
      it 'missing art_style_id return 422' do # 絵柄の指定がなかった場合
        invalid_params_art_style_id = base_attributes.deep_merge(
          post: {
            post_images_attributes: {
              '0' => { art_style_id: nil }
            }
          }
        )
        post api_v1_user_posts_path(user), params: invalid_params_art_style_id, headers:, xhr: true
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'an unexpected ID is entered' do # 絵柄に想定外の値が入る
        invalid_params_art_style_id = base_attributes.deep_merge(
          post: {
            post_images_attributes: {
              '0' => { art_style_id: 99_999 }
            }
          }
        )
        post api_v1_user_posts_path(user), params: invalid_params_art_style_id, headers:, xhr: true
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when a position' do # position について
      it 'duplicates are invalid return 422' do # position が重複すると無効
        invalid_params_position = base_attributes.deep_merge(
          post: {
            post_images_attributes: {
              '0' => { position: 0 },
              '1' => { position: 0 }
            }
          }
        )
        post api_v1_user_posts_path(user), params: invalid_params_position, headers:, xhr: true
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'nil is invalid' do # position が nil は無効(片方が nil の時点で無効)
        invalid_params_position = base_attributes.deep_merge(
          post: {
            post_images_attributes: {
              '0' => { position: nil },
              '1' => { position: 0 }
            }
          }
        )
        post api_v1_user_posts_path(user), params: invalid_params_position, headers:, xhr: true
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when a caption' do # 画像の説明について
      it 'nil is ok' do
        valid_params_caption = base_attributes.deep_merge(
          post: {
            post_images_attributes: {
              '0' => { caption: nil }
            }
          }
        )
        post api_v1_user_posts_path(user), params: valid_params_caption, headers:, xhr: true
        expect(response).to have_http_status(:created)
      end

      it 'strings greater than 1001 are invalid' do
        invalid_params_caption = base_attributes.deep_merge(
          post: {
            post_images_attributes: {
              '0' => { caption: 'a' * 1001 }
            }
          }
        )
        post api_v1_user_posts_path(user), params: invalid_params_caption, headers:, xhr: true
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when a tips' do # 描き方のコツについて
      it 'nil is ok' do
        valid_params_tip = base_attributes.deep_merge(
          post: {
            post_images_attributes: {
              '0' => { tips: nil }
            }
          }
        )
        post api_v1_user_posts_path(user), params: valid_params_tip, headers:, xhr: true
        expect(response).to have_http_status(:created)
      end
    end

    context 'when a alt' do # alt ついて
      it 'copies caption to alt when alt is nil' do # captionがあり、altがnilの場合
        valid_params_alt = base_attributes.deep_merge(
          post: {
            post_images_attributes: {
              '0' => { caption: 'This is the caption', alt: nil }
            }
          }
        )

        post api_v1_user_posts_path(user), params: valid_params_alt, headers:, xhr: true
        expect(response).to have_http_status(:created)

        created_post_image = Post.last.post_images.first # 作成された投稿の最新のデータを取得
        expect(created_post_image.alt).to eq('This is the caption') # データの中の alt が caption の中の値と同じか確認
      end

      it 'does not overwrite alt if it is already present' do # captionとaltの両方に値がある場合
        valid_params_alt = base_attributes.deep_merge(
          post: {
            # altに個別の値を設定
            post_images_attributes: {
              '0' => { caption: 'This is the caption', alt: 'This is specific alt text' }
            }
          }
        )

        post api_v1_user_posts_path(user), params: valid_params_alt, headers:, xhr: true
        expect(response).to have_http_status(:created)

        created_post_image = Post.last.post_images.first
        expect(created_post_image.alt).to eq('This is specific alt text') # altが上書きされず、送信した値のままであることを確認
      end

      it 'alt is blank when caption is nil' do # caption が nil
        valid_params_alt = base_attributes.deep_merge(
          # caption が nil の場合は strip_whitespace メソッドによって "" に変換される
          post: {
            post_images_attributes: {
              '0' => { caption: nil, alt: '' }
            }
          }
        )

        post api_v1_user_posts_path(user), params: valid_params_alt, headers:, xhr: true
        expect(response).to have_http_status(:created)

        created_post_image = Post.last.post_images.first
        expect(created_post_image.alt).to be_blank
      end
    end
  end
end
