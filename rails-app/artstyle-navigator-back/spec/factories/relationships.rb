FactoryBot.define do
  # rubocop:disable FactoryBot/AssociationStyle
  factory :relationship do
    # 関連するユーザーを生成
    association :follower, factory: :user
    association :followed, factory: :user
  end
  # rubocop:enable FactoryBot/AssociationStyle
end
