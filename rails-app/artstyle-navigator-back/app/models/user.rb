# frozen_string_literal: true

# rubocop:disable Rails/ApplicationRecord
class User < ActiveRecord::Base
  # token (refresh_token)生成モジュール
  include TokenGenerateService

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  include DeviseTokenAuth::Concerns::User
  # rubocop:enable Rails/ApplicationRecord
  validates :name, presence: true, length: { maximum: 50 }
  # email の presence: true は devise ですでに設定されているため書かない
  validates :email, length: { maximum: 255 }

  # リフレッシュトークンのJWT IDを保存
  def remember(jti)
    update!(refresh_jti: jti)
  end

  # リフレッシュトークンのJWT IDを削除
  def forget
    update!(refresh_jti: nil)
  end
end
