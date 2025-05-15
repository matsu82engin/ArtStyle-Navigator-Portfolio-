FactoryBot.define do
  factory :post_image do
    post { nil }
    art_style { nil }
    position { 1 }
    caption { 'MyString' }
    tips { 'MyText' }
    alt { 'MyString' }
  end
end
