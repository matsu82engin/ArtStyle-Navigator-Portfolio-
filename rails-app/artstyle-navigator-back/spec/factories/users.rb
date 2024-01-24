FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'password' } # PWに関してはテスト環境なので簡単なものにしておく。
  end
end
