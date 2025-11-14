class Post < ApplicationRecord
  belongs_to :user
  has_many :post_images, dependent: :destroy
  accepts_nested_attributes_for :post_images, allow_destroy: true

  # ここからカラムのバリデーション
  validates :title, presence: true, length: { maximum: 50 }
  validates :post_images, presence: true
  validate  :validate_uniqueness_of_position_per_post_images # validate で s はないので注意
  # validate :validate_uniqueness_of_position_per_post_images, if: -> { post_images.present? }

  scope :latest, -> { order(created_at: :desc) }

  private

  def validate_uniqueness_of_position_per_post_images
    positions = post_images.map(&:position)
    duplicates = positions.select { |p| positions.count(p) > 1 }.uniq
    errors.add(:post_images, "の position が重複しています（#{duplicates.join(', ')}）") if duplicates.any?
  end
end
