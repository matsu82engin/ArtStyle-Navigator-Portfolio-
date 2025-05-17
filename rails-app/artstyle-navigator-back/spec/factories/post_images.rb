FactoryBot.define do
  factory :post_image do
    post
    art_style
    position { 0 }
    caption { 'MyString' }
    tips { 'MyText' }
    alt { 'MyString' }
  end
end
