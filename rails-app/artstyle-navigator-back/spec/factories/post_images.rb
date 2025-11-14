FactoryBot.define do
  factory :post_image do
    post
    # art_style
    art_style { ArtStyle.order('RAND()').first || create(:art_style) }
    # position { 0 }
    sequence(:position) { |n| n }
    caption { 'MyString' }
    tips { 'MyText' }
    alt { 'MyString' }

    after(:build) do |post_image|
      post_image.image.attach(
        io: Rails.root.join('spec/support/test_images/sample.jpg').open,
        filename: 'sample.jpg',
        content_type: 'image/jpeg'
      )
    end
  end
end
