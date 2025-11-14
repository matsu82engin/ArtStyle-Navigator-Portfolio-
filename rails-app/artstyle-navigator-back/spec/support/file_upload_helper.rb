module FileUploadHelpers
  # デフォルトのテスト画像を返すヘルパーメソッド
  def sample_image_file(filename: 'sample.jpg', mime_type: 'image/jpeg')
    Rack::Test::UploadedFile.new(
      Rails.root.join('spec/support/test_images', filename),
      mime_type
    )
  end

  # 将来的に別の画像を使いたくなった時にも対応できるようにしておく
  def another_sample_image_file
    sample_image_file(filename: 'another.png', mime_type: 'image/png')
  end
end
