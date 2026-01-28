class Profile < ApplicationRecord
  belongs_to :user
  belongs_to :art_style, optional: true

  has_one_attached :avatar

  include Rails.application.routes.url_helpers
  include ImageValidatable

  validates :user, uniqueness: true
  validates :pen_name,
            presence: true,
            # format: { without: /\A\s*\z/, message: :blank },
            length: { maximum: 20 }

  VALID_ART_SUPPLIES = [
    'デジタルペン : ペンタブレット(ペンタブ)',
    'デジタルペン : 液晶タブレット(液タブ)',
    'つけペン : Gペン',
    'つけペン : 丸ペン',
    'つけペン : カブラペン',
    'その他'
  ].freeze

  validates :art_supply,
            inclusion: { in: VALID_ART_SUPPLIES },
            allow_nil: true

  validates :introduction,
            presence: true,
            allow_nil: true,
            length: { maximum: 500 }

  # JSON 用の URL
  def avatar_url
    return nil unless avatar.attached?

    rails_representation_url(display_avatar)
  end

  # 表示用 variant
  def display_avatar
    avatar.variant(resize_to_fill: [200, 200])
  end

  private

  def attached_image
    avatar
  end

  def attached_image_name
    :avatar
  end
end
