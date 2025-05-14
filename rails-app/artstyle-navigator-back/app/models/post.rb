class Post < ApplicationRecord
  belongs_to :user
  has_many :post_images, dependent: :destroy

  # ここからカラムのバリデーション
  validates :title, presence: true, length: { maximum: 50 }
end
