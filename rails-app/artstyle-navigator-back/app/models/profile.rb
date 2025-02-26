class Profile < ApplicationRecord
  belongs_to :user
  belongs_to :art_style, optional: true

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
  validates :art_supply, inclusion: { in: VALID_ART_SUPPLIES }, allow_nil: true
  validates :introduction,
            allow_nil: true,
            format: { without: /\A\s*\z/, message: :blank },
            length: { maximum: 500 }
end
