class ArtStyle < ApplicationRecord
  has_many :choice_art_styles, dependent: :destroy
  has_many :choices, through: :choice_art_styles
end
