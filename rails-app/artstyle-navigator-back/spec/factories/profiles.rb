FactoryBot.define do
  factory :profile do
    user #  user モデルとの関連付け(association :user)
    art_style # art_style モデルとの関連付け(association :art_style)
    pen_name { 'MyString' }
    # art_style_id { 1 } # 関連付けが行われていれば必要ない
    art_supply { 'デジタルペン : ペンタブレット(ペンタブ)' } # inclusion で選択肢以外は無効にしたので選択肢の値を設定
    introduction { Faker::Lorem.sentence }
  end
end
