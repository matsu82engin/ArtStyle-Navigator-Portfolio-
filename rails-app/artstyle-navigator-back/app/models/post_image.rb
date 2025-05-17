class PostImage < ApplicationRecord
  belongs_to :post
  belongs_to :art_style

  # ここからカラムのバリデーション
  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 },
            uniqueness: { scope: :post_id } # 複合ユニーク

  validates :caption,
            presence: true,
            allow_nil: true,
            # format: { without: /\A\s*\z/, message: :blank },
            length: { maximum: 1000 }

  validates :tips,
            presence: true,
            allow_nil: true
end
