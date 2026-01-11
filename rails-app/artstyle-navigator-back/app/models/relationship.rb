class Relationship < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User'

  # belongs_to のデフォルトで存在性のチェックがあるので presence は不要

  validates :follower_id, uniqueness: { scope: :followed_id }
end
