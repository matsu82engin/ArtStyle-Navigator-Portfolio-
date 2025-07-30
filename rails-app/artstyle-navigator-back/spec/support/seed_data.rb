# このメソッドをテスト実行前に一度だけ呼び出す
def setup_art_style_master_data
  # 冪等性（何回実行しても結果が同じ）を保つために、まずデータを消去
  ArtStyle.destroy_all

  # マスターデータ
  ArtStyle.create!(name: 'リアル系')
  ArtStyle.create!(name: 'デフォルメ系')
  ArtStyle.create!(name: 'ゆる系')
  ArtStyle.create!(name: '萌え系')
  ArtStyle.create!(name: '劇画系')
  ArtStyle.create!(name: 'レトロ系')
  ArtStyle.create!(name: 'その他')
end
