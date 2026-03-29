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

  puts '--- 質問・選択肢作成中 ---'

  questions_data = [
    {
      text: '好きなキャラクターの体つきはどれに近いですか？',
      position: 1,
      choices: [
        { label: 'A', text: 'モデルのようにスラっとしたリアルな体型', art_styles: ['リアル系', '劇画系'] },
        { label: 'B', text: 'がっしりした筋肉質な体格', art_styles: ['劇画系'] },
        { label: 'C', text: '頭が大きく体が小さいデフォルメ体型', art_styles: ['デフォルメ系'] },
        { label: 'D', text: '華奢で手足が細長いスタイル', art_styles: ['萌え系'] },
        { label: 'E', text: '全体的に丸みがあり親しみやすい体型', art_styles: ['レトロ系'] },
        { label: 'F', text: '特に体型は気にしない・シンプルな線だけでいい ', art_styles: ['ゆる系'] },
      ]
    },

    {
      text: 'キャラクターの目はどんな印象が好きですか？',
      position: 2,
      choices: [
        { label: 'A', text: '解剖学的に正確な、現実に近い目', art_styles: ['リアル系'] },
        { label: 'B', text: '顔の半分近くを占める、描き込まれた大きな瞳', art_styles: ['萌え系'] },
        { label: 'C', text: '感情に合わせて形が変わる、シンプルで大きな目', art_styles: ['デフォルメ系'] },
        { label: 'D', text: '点やドットのような最小限の目', art_styles: ['ゆる系'] },
        { label: 'E', text: '鋭く眼光の強い、圧迫感のある目', art_styles: ['劇画系'] },
        { label: 'F', text: '縦長のパッチリとした、昭和アニメ風の目', art_styles: ['レトロ系'] },
      ]
    },
    
    {
      text: '目の輪郭（アイフレーム）の形はどれが好きですか？',
      position: 3,
      choices: [
        { label: 'A', text: 'アーモンド型で目頭の切れ込みまで描かれたリアルな形', art_styles: ['リアル系'] },
        { label: 'B', text: '感情に合わせて丸や逆三角形に変わる記号的な形', art_styles: ['デフォルメ系'] },
        { label: 'C', text: '点や短い曲線だけで、フレーム自体がほぼない', art_styles: ['ゆる系'] },
        { label: 'D', text: '上のラインだけが主役で、横に跳ねて存在感がある形', art_styles: ['萌え系'] },
        { label: 'E', text: '鋭く角張っていて、眉や影と一体化した形', art_styles: ['劇画系'] },
        { label: 'F', text: '縦長の楕円形で、まつ毛と一体化したお椀のような形', art_styles: ['レトロ系'] },
      ]
    },

    {
      text: 'キャラクターの鼻はどう描かれているのが好きですか？',
      position: 4,
      choices: [
        { label: 'A', text: '鼻筋・小鼻まで構造的に描かれている', art_styles: ['リアル系'] },
        { label: 'B', text: '影や線で立体感を強調して描かれている', art_styles: ['劇画系'] },
        { label: 'C', text: '小さな「く」の字や点だけ' , art_styles: ['デフォルメ系', '萌え系'] },
        { label: 'D', text: '省略されていて、ほぼない', art_styles: ['デフォルメ系', 'ゆる系'] },
        { label: 'E', text: 'デフォルメしつつ存在感がある（団子鼻など', art_styles: ['レトロ系'] },
      ]
    },

    {
      text: 'キャラクターの瞳はどんなものが好きですか？',
      position: 5,
      choices: [
        { label: 'A', text: '現実的なサイズで虹彩や瞳孔まで描かれている', art_styles: ['リアル系'] },
        { label: 'B', text: 'フレームいっぱいの大きさでキラキラしている', art_styles: ['デフォルメ系'] },
        { label: 'C', text: 'グラデーションや複雑な反射光が入った巨大な瞳', art_styles: ['萌え系'] },
        { label: 'D', text: '点や黒丸だけのシンプルな瞳', art_styles: ['ゆる系'] },
        { label: 'E', text: '白目が広く、鋭さや圧迫感がある小さめの瞳', art_styles: ['劇画系'] },
        { label: 'F', text: '縦長で大きな白いハイライトが入る昭和風の瞳', art_styles: ['レトロ系'] },
      ]
    },

    {
      text: 'キャラクターを構成する線の雰囲気はどれが好きですか？',
      position: 6,
      choices: [
        { label: 'A', text: '細くシャープで均一な線', art_styles: ['リアル系'] },
        { label: 'B', text: '太くてはっきりした力強い線', art_styles: ['デフォルメ系'] },
        { label: 'C', text: '極細の脱力感ある線', art_styles: ['ゆる系'] },
        { label: 'D', text: '外郭は太く細部は極細のメリハリある線', art_styles: ['萌え系'] },
        { label: 'E', text: '筆の強弱が激しく重みのある線', art_styles: ['劇画系'] },
        { label: 'F', text: 'サインペンのような強弱の少ない均一な線', art_styles: ['レトロ系'] },
      ]
    },

    {
      text: 'キャラクターの「情報量」はどれくらいが好きですか？',
      position: 7,
      choices: [
        { label: 'A', text: '背景・筋肉・衣服のシワまで細かく描き込まれている', art_styles: ['リアル系'] },
        { label: 'B', text: 'カケアミや点描、影が多く、圧倒的な密度がある', art_styles: ['劇画系'] },
        { label: 'C', text: '瞳や髪のハイライト・衣装の装飾が細かい', art_styles: ['萌え系'] },
        { label: 'D', text: 'シンプルなシルエット重視でスッキリしている', art_styles: ['デフォルメ系'] },
        { label: 'E', text: '均一なトーンで装飾より形を優先している', art_styles: ['レトロ系'] },
        { label: 'F', text: 'ほとんど描き込まず、余白を活かしている', art_styles: ['ゆる系'] },
      ]
    },
  ]

  questions_data.each do |q_data|
    question = Question.find_or_create_by!(text: q_data[:text]) do |q|
      q.position = q_data[:position]
    end

    q_data[:choices].each do |c_data|
      choice = Choice.find_or_create_by!(question:, label: c_data[:label]) do |c|
        c.text = c_data[:text]
      end
      
      c_data[:art_styles].each do |style_name|
        art_style = ArtStyle.find_by!(name: style_name)
        ChoiceArtStyle.find_or_create_by!(choice:, art_style:)
      end
    end
  end

  puts '質問・選択肢作成完了！'

  # 投稿作成
  puts '--- 投稿作成中 ---'

  image_paths = Dir[Rails.root.join('db/images/*')].map { |p| Pathname.new(p) }

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
