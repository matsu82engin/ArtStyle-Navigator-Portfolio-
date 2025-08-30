require 'rails_helper'

RSpec.describe Profile, type: :model do
  let(:user) { build(:user) }
  let(:art_style) { build(:art_style) }
  let(:profile) { build(:profile) }

  context 'with valid profile' do # 有効な属性の場合
    it 'is valid' do
      expect(profile).to be_valid
    end
  end

  context 'when user is not associated' do # プロフィールの user_id が存在しない時
    it 'is invalid' do # 関連付けを行うユーザーがいないと無効
      profile = build(:profile, user: nil) # build で user を nil に指定
      expect(profile).to be_invalid
    end
  end

  context 'when profile_pen_name is invalid' do # プロフィールの pen_name が有効な値でない時
    it 'is invalid when pen_name is too long' do # pen_nameが長すぎるため無効(20文字まで)
      profile = build(:profile, pen_name: 'a' * 21)
      expect(profile).to be_invalid
    end

    it 'is invalid when pen_name is blank' do # pen_name が空白のため無効
      profile = build(:profile, pen_name: ' ')
      expect(profile).to be_invalid
    end

    it 'is invalid when pen_name is null' do # pen_name が null のため無効
      profile = build(:profile, pen_name: nil)
      expect(profile).to be_invalid
    end
  end

  context 'when profile_art_style is nil' do # プロフィールの絵柄の id が nil でもプロフィール編集は可能
    it 'is valid' do
      profile = build(:profile, art_style: nil) # build で art_style を nil に指定
      expect(profile).to be_valid
    end
  end

  context 'when profile_art_supply' do # プロフィールの art_supply
    it 'is valid with a valid art_supply' do # 有効な値
      profile = build(:profile, art_supply: 'デジタルペン : ペンタブレット(ペンタブ)')
      expect(profile).to be_valid
    end

    it 'is invalid when art_supply is nil' do # 選択肢が nil は有効
      profile = build(:profile, art_supply: nil)
      expect(profile).to be_valid
    end

    it 'is invalid with an invalid art_supply' do # 選択肢以外の値のため無効
      profile = build(:profile, art_supply: 'a: a')
      expect(profile).to be_invalid
    end

    it 'is invalid when art_supply is blank' do # 選択肢が空白のため無効
      profile = build(:profile, art_supply: '')
      expect(profile).to be_invalid
    end
  end

  context 'when profile_introduction is invalid' do # プロフィールの 自己紹介 が有効な値でないとき
    it 'is invalid when introduction is too long' do # 自己紹介が長すぎるため無効(500文字まで)
      profile = build(:profile, introduction: 'a' * 501)
      expect(profile).to be_invalid
    end

    it 'is invalid when introduction is blank' do # 自己紹介が空白は無効
      profile = build(:profile, introduction: '')
      expect(profile).to be_invalid
    end

    it 'is valid when introduction is nil' do # 自己紹介を書かないのは有効
      profile = build(:profile, introduction: nil)
      expect(profile).to be_valid
    end
  end
end
