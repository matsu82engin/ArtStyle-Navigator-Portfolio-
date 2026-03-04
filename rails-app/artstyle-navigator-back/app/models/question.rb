class Question < ApplicationRecord
  validates :text, presence: true
  validates :position, presence: true, uniqueness: true
end
