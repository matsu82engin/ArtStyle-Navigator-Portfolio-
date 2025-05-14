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
        expect(post).not_to be_valid
        expect(post.errors[:title]).to include("can't be blank")
      end

      it 'when title is too long' do # タイトルが50文字を超えると無効
        post.title = 'a' * 51
        expect(post).not_to be_valid
        expect(post.errors[:title]).to include('is too long (maximum is 50 characters)')
      end

      it 'without a user' do # ユーザーが紐付いていない場合は無効
        post_without_user = build(:post, user: nil, title: 'Some title')
        expect(post_without_user).not_to be_valid
        expect(post_without_user.errors[:user]).to include('must exist')
      end
    end
  end
end
