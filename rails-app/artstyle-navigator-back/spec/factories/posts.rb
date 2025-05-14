FactoryBot.define do
  factory :post do
    user
    title { "サンプルタイトル" }
  end
end
