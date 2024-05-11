# メインのサンプルユーザーを1人作成する
User.create!(name: 'Example User',
             email: 'sample@example.com',
             password: 'password')

# 追加のユーザーをまとめて生成する
9.times do |n|
  name = "user#{n + 1}"
  email = "#{n + 1}@example.com"
  password = 'password'
  User.create!(name: name,
               email: email,
               password: password)
end
