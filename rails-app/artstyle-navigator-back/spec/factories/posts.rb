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
