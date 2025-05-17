require 'rails_helper'

RSpec.describe PostImage, type: :model do
  let(:post) { create(:post) }
  let(:art_style) { create(:art_style) }
  let(:post_image) { build(:post_image, post:, art_style:) }

  context 'with valid attributes' do # 有効な属性
    it 'is valid with default values' do # デフォルト値は有効
      expect(post_image).to be_valid
    end

    it 'is valid when caption is 1000' do # caption が 1000 文字は有効(境界値テスト)
      post_image.caption = 'a' * 1000
      expect(post_image).to be_valid
    end

    it 'is valid when caption nil' do # caption が nil は有効
      post_image.caption = nil
      expect(post_image).to be_valid
    end

    it 'is valid when tips nil' do # tips が nil は有効
      post_image.tips = nil
      expect(post_image).to be_valid
    end

    it 'is valid when alt nil' do # alt が nil は有効
      post_image.alt = nil
      expect(post_image).to be_valid
    end
  end

  context 'with invalid attributes foreign_key' do # 外部キーの無効な属性
    it 'is invalid without a post' do # post と関連づいていない
      post_image.post = nil # これで post_id カラムを nil にしてくれる
      expect(post_image).to be_invalid
      expect(post_image.errors[:post]).to include('must exist')
    end

    it 'is invalid without an art_style' do # art_style と関連づいていない
      post_image.art_style = nil
      expect(post_image).to be_invalid
      expect(post_image.errors[:art_style]).to include('must exist')
    end
  end

  context 'with invalid attributes position' do # position の無効な属性
    it 'is invalid when position is nil' do # position が nil は無効
      post_image.position = nil
      expect(post_image).to be_invalid
      expect(post_image.errors[:position]).to include("can't be blank")
    end

    it 'is invalid when position is not an integer' do # position が文字列は無効
      post_image.position = 'abc'
      expect(post_image).to be_invalid
      expect(post_image.errors[:position]).to include('is not a number')
    end

    it 'is invalid when position is a float' do # position が小数点は無効
      post_image.position = 1.5
      expect(post_image).to be_invalid
      expect(post_image.errors[:position]).to include('must be an integer')
    end

    it 'is invalid when position is negative' do # position が負の値は無効
      post_image.position = -1
      expect(post_image).to be_invalid
      expect(post_image.errors[:position]).to include('must be greater than or equal to 0')
    end

    it 'is invalid if [post_id, position] is duplicated' do # position は複合ユニーク制約により重複していたら無効
      create(:post_image, post:, art_style:, position: 1)
      duplicate = build(:post_image, post:, art_style:, position: 1)
      expect(duplicate).to be_invalid
      expect(duplicate.errors[:position]).to include('has already been taken')
    end

    it 'is valid if position is duplicated but for a different post' do # 違う投稿であれば、同じ position でも有効
      create(:post_image, post:, art_style:, position: 1)
      another_post = create(:post) # 別のPostを作成
      valid_duplicate = build(:post_image, post: another_post, art_style:, position: 1)
      expect(valid_duplicate).to be_valid
    end
  end

  context 'with invalid attributes caption' do # caption の無効な属性
    it 'is invalid when caption is too long' do # caption が 1001 文字
      post_image.caption = 'a' * 1001
      expect(post_image).to be_invalid
      expect(post_image.errors[:caption]).to include('is too long (maximum is 1000 characters)')
    end

    it 'is invalid when caption spaces only' do # caption で空文字は無効
      post_image.caption = '' # 空白
      expect(post_image).to be_invalid
      expect(post_image.errors[:caption]).to include("can't be blank")
    end

    it 'is invalid when caption multiple spaces only' do # caption で複数空白のみは無効
      post_image.caption = '     ' # 空白５つ(複数)
      expect(post_image).to be_invalid
      expect(post_image.errors[:caption]).to include("can't be blank")
    end
  end

  context 'with invalid attributes tips' do # tips の無効な属性
    it 'is invalid when tips spaces only' do # tips で空文字は無効
      post_image.tips = '' # 空白
      expect(post_image).to be_invalid
      expect(post_image.errors[:tips]).to include("can't be blank")
    end

    it 'is invalid when tips multiple spaces only' do # tips で複数空白のみは無効
      post_image.tips = '     ' # 空白５つ(複数)
      expect(post_image).to be_invalid
      expect(post_image.errors[:tips]).to include("can't be blank")
    end
  end
end
