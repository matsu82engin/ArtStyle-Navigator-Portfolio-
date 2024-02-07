# frozen_string_literal: true

# rubocop:disable Rails/ApplicationRecord
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User
  # rubocop:enable Rails/ApplicationRecord
  validates :name, presence: true, length: { maximum: 50 }
  # email の presence: true は devise ですでに設定されているため書かない
  validates :email, length: { maximum: 255 }
end
