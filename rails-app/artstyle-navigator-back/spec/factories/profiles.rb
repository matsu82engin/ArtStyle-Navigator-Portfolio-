FactoryBot.define do
  factory :profile do
    user #  user モデルとの関連付け(association :user)
    pen_name { 'MyString' }
    art_supply { 'デジタルペン : ペンタブレット(ペンタブ)' } # inclusion で選択肢以外は無効にしたので選択肢の値を設定
    introduction { Faker::Lorem.sentence }

    # 「好みの絵柄を持っている」状態を作るための trait を定義
    trait :with_favorite_art_style do
      # 関連付けは trait の中で行う
      art_style { ArtStyle.order('RAND()').first || create(:art_style) } # 既存のマスターデータからランダムに選ぶ
    end
  end
end
