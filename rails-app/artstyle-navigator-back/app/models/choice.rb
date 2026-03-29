class Choice < ApplicationRecord
  belongs_to :question

  has_many :choice_art_styles, dependent: :destroy
  has_many :art_styles, through: :choice_art_styles

  validates :text, presence: true
  validates :label,
            presence: true,
            inclusion: { in: %w[A B C D E F] }
end
