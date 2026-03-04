class Choice < ApplicationRecord
  belongs_to :question

  validates :text, presence: true
  validates :label, presence: true,
            inclusion: { in: %w[A B C D E F] }
end
