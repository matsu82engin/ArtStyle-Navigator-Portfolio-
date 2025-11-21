FactoryBot.define do
  factory :relationship do
    # 関連するユーザーを生成
    association :follower, factory: :user
    association :followed, factory: :user
  end
end
