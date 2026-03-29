class Question < ApplicationRecord
  has_many :choices, dependent: :destroy

  validates :text, presence: true
  validates :position, presence: true, uniqueness: true
end
