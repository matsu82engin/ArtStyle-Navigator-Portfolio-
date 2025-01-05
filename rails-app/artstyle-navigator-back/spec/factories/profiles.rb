FactoryBot.define do
  factory :profile do
    user { nil }
    pen_name { "MyString" }
    art_style { nil }
    art_supply { "MyString" }
    introduction { "MyText" }
  end
end
