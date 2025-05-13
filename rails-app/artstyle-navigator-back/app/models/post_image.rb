class PostImage < ApplicationRecord
  belongs_to :post
  belongs_to :art_style

  # ここからカラムのバリデーション
end
