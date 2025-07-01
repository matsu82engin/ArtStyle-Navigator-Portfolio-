# メインのサンプルユーザーを1人作成する
User.create!(name: 'Example User',
             email: 'sample@example.com',
             password: 'password',
             password_confirmation: 'password')

# 追加のユーザーをまとめて生成する
9.times do |n|
  name = "user#{n + 1}"
  email = "#{n + 1}@example.com"
  password = 'password'
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: 'password')
end

# 絵柄マスター（ArtStyle）
art_styles = [
  'リアル系',
  'デフォルメ系',
  'ゆる系',
  '萌え系',
  '劇画系',
  'レトロ系',
  'その他'
]

art_styles.each do |name|
  ArtStyle.find_or_create_by!(name: name)
end
