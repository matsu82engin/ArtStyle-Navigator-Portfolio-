require 'rails_helper'

RSpec.describe Relationship, type: :model do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  # user が other_user をフォロー
  let(:relationship) { user.active_relationships.build(followed_id: other_user.id)}
  # let(:relationship) { create(:relationship)}

  context 'with valid associations' do # 有効なフォロー
    it 'follower_id and followed_id present is valid' do # follower_id と followed_id があれば有効
      expect(relationship).to be_valid
    end
  end

  context 'when either follower_id or followed_id is nil' do # follower_id, followed_id どちらかが nil の場合
    it 'follower_id is nil invalid' do # follower_id が nil は無効
      relationship.follower_id = nil
      expect(relationship).to be_invalid
    end

    it 'followed_id is nil invalid' do # followed_id が nil は無効
      relationship.followed_id = nil
      expect(relationship).to be_invalid
    end
  end

  context 'when uniqueness verification' do # 一意性の検証
    it 'the combination of follower_id and followed_id is unique' do # follower_id と followed_id の組み合わせは一意である
      relationship.save
      duplicate_relationship = relationship.dup
      expect(duplicate_relationship).to be_invalid
    end
  end
end
