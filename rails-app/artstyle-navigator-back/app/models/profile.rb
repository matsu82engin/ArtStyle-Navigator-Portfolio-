class Profile < ApplicationRecord
  belongs_to :user
  belongs_to :art_style, optional: true

  validates :user, presence: true
  validates :pen_name, allow_nil: true, allow_blank: false, length: { maximum: 20 }
  VALID_ART_SUPPLIES = [
    "デジタルペン : ペンタブレット(ペンタブ)",
    "デジタルペン : 液晶タブレット(液タブ)",
    "つけペン : Gペン",
    "つけペン : 丸ペン",
    "つけペン : カブラペン",
    "その他"
  ]
  validates :art_supply, inclusion: { in: VALID_ART_SUPPLIES }, allow_nil: true
  validates :introduction, allow_nil: true, allow_blank: false, length: { maximum: 500 }
end
