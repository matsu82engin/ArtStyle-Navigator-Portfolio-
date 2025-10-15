FactoryBot.define do
  factory :post_image do
    post
    # art_style
    art_style { ArtStyle.order('RAND()').first || create(:art_style) }
    position { 0 }
    caption { 'MyString' }
    tips { 'MyText' }
    alt { 'MyString' }

    after(:build) do |post_image|
      post_image.image.attach(
        io: File.open(Rails.root.join('spec/support/test_images/sample.jpg')),
        filename: 'sample.jpg',
        content_type: 'image/jpeg'
      )
    end
  end
end