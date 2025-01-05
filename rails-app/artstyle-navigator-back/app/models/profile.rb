class Profile < ApplicationRecord
  belongs_to :user
  belongs_to :art_style
end
