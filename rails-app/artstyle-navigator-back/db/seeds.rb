# rubocop:disable Metrics/BlockLength

require_relative '../lib/seed_utils/mime_type_helper'

ActiveRecord::Base.transaction do
  puts '--- データをリセット中 ---'
  Post.destroy_all 

  puts '--- ユーザー作成中 ---'

  users = []

  users << User.find_or_create_by!(email: 'sample@example.com') do |u|
    u.name = 'Example User'
    u.password = 'password'
    u.password_confirmation = 'password'
  end

  19.times do |n|
    email = "#{n + 1}@example.com"
    users << User.find_or_create_by!(email:) do |u|
      u.name = "user#{n + 1}"
      u.password = 'password'
      u.password_confirmation = 'password'
    end
  end

  puts 'ユーザー作成完了！'

  # ArtStyle 作成
  puts '--- 絵柄マスター作成 ---'

  # rubocop:disable Style/WordArray
  art_styles = [
    'リアル系',
    'デフォルメ系',
    'ゆる系',
    '萌え系',
    '劇画系',
    'レトロ系',
    'その他'
  ]
  # rubocop:enable Style/WordArray

  art_styles.each do |name|
    ArtStyle.find_or_create_by!(name:)
  end

  puts '絵柄マスター作成完了！'

  # 投稿作成
  puts '--- 投稿作成中 ---'

  image_paths = [
    Rails.root.join('spec/support/test_images/sample.jpg'),
    Rails.root.join('spec/support/test_images/sample2.jpg'),
    Rails.root.join('spec/support/test_images/resize_sample.jpg')
  ]

  # 画像存在チェック
  unless image_paths.all? { |p| File.exist?(p) }
    missing = image_paths.reject { |p| File.exist?(p) }
    raise "画像ファイルがありません: #{missing.join(', ')}"
  end

  art_styles = ArtStyle.all
  users_to_post = User.order(:created_at).limit(5)

  users_to_post.each do |user|
    rand(1..5).times do
      post = user.posts.new(title: 'こんにちは')

      style = art_styles.sample
      caption = 'テスト画像の説明です'

      post_image = post.post_images.new(
        art_style: style,
        caption:,
        position: 0
      )

      selected = image_paths.sample

      File.open(selected) do |file|
        post_image.image.attach(
          io: StringIO.new(file.read),
          filename: selected.basename,
          content_type: SeedUtils::MimeTypeHelper.mime_type_from(selected.extname)
        )
      end

      post.save!

      # 投稿を事前にリサイズ
      print '.' # 進捗表示
      post_image.display_image.processed
    end
  end

  puts '投稿作成完了！'

  # フォロー関係
  puts '--- フォロー関係作成中 ---'

  all_users = User.all
  main_user = all_users.first

  # 自動的に 15 人・10 人を抽出
  following_users = all_users.where.not(id: main_user.id).limit(15)
  follower_users  = all_users.where.not(id: main_user.id).offset(5).limit(10)

  following_users.each do |u|
    main_user.follow(u) unless main_user.following?(u)
  end

  follower_users.each do |u|
    u.follow(main_user) unless u.following?(main_user)
  end

  # 相互フォローの例（既に関係があれば作らない）
  u1 = all_users[1]
  u2 = all_users[2]

  u1.follow(u2) unless u1.following?(u2)
  u2.follow(u1) unless u2.following?(u1)

  puts 'フォロー関係作成完了！'
  puts '--- seeds 完了 ---'
end

# rubocop:enable Metrics/BlockLength
