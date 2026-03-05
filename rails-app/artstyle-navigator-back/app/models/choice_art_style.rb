class ChoiceArtStyle < ApplicationRecord
  belongs_to :choice
  belongs_to :art_style

  validates :choice_id, uniqueness: { scope: :art_style_id }
end
