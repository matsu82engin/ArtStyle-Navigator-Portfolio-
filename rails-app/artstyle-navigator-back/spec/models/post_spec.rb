require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'validations' do
    let!(:user) { create(:user) }
    let(:post) { build(:post, user:) }

    context 'with valid attributes' do # 有効な投稿
      it 'is valid' do
        expect(post).to be_valid
      end

      it 'is valid when title is exactly 50 characters long' do # タイトルが50文字ちょうどなら有効
        post.title = 'a' * 50
        expect(post).to be_valid
      end
    end

    context 'with invalid attributes' do # 無効な投稿
      it 'without a title' do # タイトルがない場合は無効
        post.title = nil
        expect(post).to be_invalid
        expect(post.errors[:title]).to include("can't be blank")
      end

      it 'when title is too long' do # タイトルが50文字を超えると無効
        post.title = 'a' * 51
        expect(post).to be_invalid
        expect(post.errors[:title]).to include('is too long (maximum is 50 characters)')
      end

      it 'without a user' do # ユーザーが紐付いていない場合は無効
        post_without_user = build(:post, user: nil, title: 'Some title')
        expect(post_without_user).to be_invalid
        expect(post_without_user.errors[:user]).to include('must exist')
      end
    end

    context 'when regarding post_images' do # 投稿画像について
      let(:post_with_title_and_user) { build(:post, user:, title: 'Valid Title') } # title と user は有効な状態

      it 'is invalid without any post_images' do
        post_without_images = build(:post, :without_images, title: 'Valid Title') # trait + transient (:without)を使って画像をつけない投稿にする
        expect(post_without_images).to be_invalid
        expect(post_without_images.errors[:post_images]).to include("can't be blank")
      end

      it 'is invalid if post_images_attributes is an empty array' do
        post_without_images = build(:post, :without_images, title: 'Valid Title')
        post_without_images.post_images_attributes = [] # この操作自体は post_images の状態を変えない
        expect(post_without_images).to be_invalid
        expect(post_without_images.errors[:post_images]).to include("can't be blank")
      end
    end

    context 'when a user makes multiple posts' do
      let!(:old_post) { create(:post, user:, created_at: 1.day.ago) }
      let!(:new_post) { create(:post, user:, created_at: 1.hour.ago) }
      let!(:middle_post) { create(:post, user:, created_at: 12.hours.ago) }

      it 'is sort latest' do
        # expect(Post.latest).to eq [new_post, middle_post, old_post] # Post.all の代わりに、Post.latest を使ってテスト
        expect(described_class.latest).to eq [new_post, middle_post, old_post]
      end
    end

    context 'when a post is deleted' do
      let!(:sample_post) { create(:post, user:) }

      it 'is posted images will also be deleted.' do
        expect { sample_post.destroy }.to change(PostImage, :count).by(-1)
      end
    end
  end
end
