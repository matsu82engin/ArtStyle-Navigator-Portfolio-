FactoryBot.define do
  factory :post_image do
    post
    # art_style
    art_style { ArtStyle.order('RAND()').first || create(:art_style) }
    position { 0 }
    caption { 'MyString' }
    tips { 'MyText' }
    alt { 'MyString' }
  end
end
