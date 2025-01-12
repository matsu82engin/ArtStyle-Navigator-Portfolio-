FactoryBot.define do
  factory :art_style do
    # name { "MyString" }
    # description { "MyString" }
    # thumbnail_url { "MyString" }
    name { Faker::Lorem.unique.word } # Fakerでユニークな値を生成
    description { Faker::Lorem.sentence }
    thumbnail_url { Faker::Internet.url }
  end
end
