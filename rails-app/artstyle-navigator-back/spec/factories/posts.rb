# FactoryBot.define do
#   factory :post do
#     user
#     title { 'サンプルタイトル' }
#   end
# end

# FactoryBot.define do
#   factory :post do
#     user
#     title { 'サンプルタイトル' }
#     after(:build) do |post|
#       if post.post_images.empty?
#         post.post_images << build(:post_image, post:)
#       end
#     end
#   end
# end

# FactoryBot.define do
#   factory :post do
#     user
#     title { 'サンプルタイトル' }

#     # 画像付きのPostを作るためのTraitを定義
#     trait :with_images do
#       after(:build) do |post_instance| # post_instance はビルド中のPostオブジェクト
#         # このTraitが指定されたときだけ、PostImageを1つビルドして関連付ける
#         # post_images が空かどうかをチェックする必要はない（Trait指定時だけ作るため）
#         post_instance.post_images << build(:post_image, post: post_instance)
#         # 複数枚つけたい場合は build_list(:post_image, 3, post: post_instance) なども可能
#       end
#     end
#   end
# end

FactoryBot.define do
  factory :post do
    user
    title { 'サンプルタイトル' }

    transient do
      # true にすると画像が自動で1つ付く。false にすると付かない。デフォルトは true (画像あり)。
      auto_include_images { true }
    end

    after(:build) do |post_object, evaluator|
      if evaluator.auto_include_images && post_object.post_images.empty?
        post_object.post_images << build(:post_image, post: post_object)
      end
    end

    # 画像を含まないPostを作るためのTrait
    trait :without_images do
      transient do
        auto_include_images { false } # このTraitが指定されたら画像を含めない
      end
    end
  end
end
