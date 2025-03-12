FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'password' } # PWに関してはテスト環境なので簡単なものにしておく。
    password_confirmation { 'password' }
    role { 'owner' }
  end
end
