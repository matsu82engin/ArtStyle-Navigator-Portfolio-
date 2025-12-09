require 'rails_helper'

RSpec.describe PostImage, type: :model do
  let(:post) { build(:post) }
  let(:art_style) { post.post_images.first.art_style }
  let(:post_image) { post.post_images.first }

  context 'with valid attributes' do # 有効な属性
    it 'is valid with default values' do # デフォルト値は有効
      expect(post_image).to be_valid
    end

    it 'is valid when caption is 1000' do # caption が 1000 文字は有効(境界値テスト)
      post_image.caption = 'a' * 1000
      expect(post_image).to be_valid
    end

    it 'is valid when caption nil' do # caption が nil は有効
      post_image.caption = nil
      expect(post_image).to be_valid
    end

    it 'is valid when tips nil' do # tips が nil は有効
      post_image.tips = nil
      expect(post_image).to be_valid
    end

    it 'is valid when alt nil' do # alt が nil は有効
      post_image.alt = nil
      expect(post_image).to be_valid
    end
  end

  context 'with invalid attributes foreign_key' do # 外部キーの無効な属性
    it 'is invalid without a post' do # post と関連づいていない
      post_image.post = nil # これで post_id カラムを nil にしてくれる
      expect(post_image).to be_invalid
      expect(post_image.errors[:post]).to include('must exist')
    end

    it 'is invalid without an art_style' do # art_style と関連づいていない
      post_image.art_style = nil
      expect(post_image).to be_invalid
      expect(post_image.errors[:art_style]).to include('must exist')
    end
  end

  context 'with invalid attributes position' do # position の無効な属性
    it 'is invalid when position is nil' do # position が nil は無効
      post_image.position = nil
      expect(post_image).to be_invalid
      expect(post_image.errors[:position]).to include("can't be blank")
    end

    it 'is invalid when position is not an integer' do # position が文字列は無効
      post_image.position = 'abc'
      expect(post_image).to be_invalid
      expect(post_image.errors[:position]).to include('is not a number')
    end

    it 'is invalid when position is a float' do # position が小数点は無効
      post_image.position = 1.5
      expect(post_image).to be_invalid
      expect(post_image.errors[:position]).to include('must be an integer')
    end

    it 'is invalid when position is negative' do # position が負の値は無効
      post_image.position = -1
      expect(post_image).to be_invalid
      expect(post_image.errors[:position]).to include('must be greater than or equal to 0')
    end

    it 'is invalid if [post_id, position] is duplicated' do # position は複合ユニーク制約により重複していたら無効
      create(:post_image, post:, art_style:, position: 1)
      duplicate = build(:post_image, post:, art_style:, position: 1)
      expect(duplicate).to be_invalid
      expect(duplicate.errors[:position]).to include('has already been taken')
    end

    it 'is valid if position is duplicated but for a different post' do # 違う投稿であれば、同じ position でも有効
      # create(:post_image, post:, art_style:, position: 1)
      # another_post = create(:post) # 別のPostを作成
      # valid_duplicate = build(:post_image, post: another_post, art_style:, position: 1)
      # expect(valid_duplicate).to be_valid

      post1 = create(:post)
      create(:post_image, post: post1, position: 1)

      # 2つ目の投稿を作成
      post2 = create(:post)
      # 別の投稿であれば、同じpositionでも有効なはず
      # art_styleはFactoryが勝手に選んでくれるので、ここでは意識しなくて良い
      valid_duplicate = build(:post_image, post: post2, position: 1)

      expect(valid_duplicate).to be_valid
    end
  end

  context 'with invalid attributes caption' do # caption の無効な属性
    it 'is invalid when caption is too long' do # caption が 1001 文字
      post_image.caption = 'a' * 1001
      expect(post_image).to be_invalid
      expect(post_image.errors[:caption]).to include('is too long (maximum is 1000 characters)')
    end
  end

  context 'when handling whitespace in caption' do
    it 'strips leading and trailing whitespace' do # 前後に空白がある文字列がトリミングされること
      post_image.caption = '  hello world  '
      post_image.valid?
      expect(post_image.caption).to eq 'hello world'
    end

    it 'converts a string with only whitespace to an empty string' do # 空白のみの文字列が空文字列になること
      post_image.caption = '   '
      post_image.valid?
      expect(post_image.caption).to eq ''
    end

    it 'strips full-width spaces' do # 前後に全角空白がある文字列がトリミングされること
      post_image.caption = '　こんにちは　'
      post_image.valid?
      expect(post_image.caption).to eq 'こんにちは'
    end
  end

  context 'when caption is nil' do
    it 'does not raise an error' do # nil の場合にエラーにならないこと
      post_image.caption = nil
      expect { post_image.valid? }.not_to raise_error
    end
  end

  context 'with blank tips' do # tip も空文字でも保存できる
    it 'is valid' do
      post_image.tips = '   '
      expect(post_image).to be_valid
    end
  end

  context 'with Image validation' do # 画像そのものに対するバリデーション
    it 'is invalid when an unauthorized format file' do # 許可されていない形式のファイルは無効
      post_image = build(:post_image)

      path = Rails.root.join('spec/support/test_images/sample.pdf')

      File.open(path) do |file|
        post_image.image.attach(
          io: StringIO.new(file.read),
          filename: 'sample.pdf',
          content_type: 'application/pdf'
        )
      end

      expect(post_image).to be_invalid
      expect(post_image.errors[:image]).to include('はPNGまたはJPEG形式でアップロードしてください')
    end

    it 'is Invalid when image size is larger than 5MB' do # 画像の容量が 5MB より大きければ無効
      post_image = build(:post_image)

      # ダミーファイルを作る
      large_file = Tempfile.new(['large_image', '.jpg'])
      begin
        large_file.write('a' * 6.megabytes) # 6MBの疑似データ
        large_file.rewind

        post_image.image.attach(io: large_file, filename: 'large_image.jpg', content_type: 'image/jpeg')

        expect(post_image).to be_invalid
        expect(post_image.errors[:image]).to include('は5MB以下にしてください')
      ensure
        large_file.close
        large_file.unlink
      end
    end

    it 'resizes image to within 800x800 pixels' do
      # ファクトリで post_image を作成
      post_image = create(:post_image)

      # テスト用の大きい画像をアタッチし直す
      path = Rails.root.join('spec/support/test_images/resize_sample.jpg')

      File.open(path) do |file|
        post_image.image.attach(io: StringIO.new(file.read), filename: 'resize_sample.jpg', content_type: 'image/jpeg')
      end

      # display_image メソッドを呼び出して、variant オブジェクトを取得
      # variant = post_image.display_image
      variant = post_image.display_image.processed

      # variant の内容をバイナリデータとしてダウンロードし、MiniMagickで読み込む
      # Tempfile を使わず、メモリ上で直接読み込める
      image_data = variant.download
      image = MiniMagick::Image.read(image_data)

      # リサイズ後の画像のサイズを検証
      expect(image.width).to be <= 800
      expect(image.height).to be <= 800
    end
  end
end
