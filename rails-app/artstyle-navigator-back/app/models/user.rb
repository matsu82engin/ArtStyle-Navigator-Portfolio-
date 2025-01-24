# rubocop:disable Rails/ApplicationRecord
class User < ActiveRecord::Base
  has_one :profile, dependent: :destroy

  devise  :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable

  # token (refresh_token)生成モジュール
  include TokenGenerateService
  include DeviseTokenAuth::Concerns::User
  before_save { self.email = email.downcase }
  # rubocop:enable Rails/ApplicationRecord
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, uniqueness: true, length: { maximum: 255 }

  # リフレッシュトークンのJWT IDを保存
  def remember(jti)
    update!(refresh_jti: jti)
  end

  # リフレッシュトークンのJWT IDを削除
  def forget
    update!(refresh_jti: nil)
  end

  # 認可のヘルパーメソッド
  # 一般ユーザーかどうか
  def guest?
    role == 'guest'
  end

  # リソース所有者かどうか
  def owner?
    role == 'owner' || admin?
  end

  # 管理者かどうか
  def admin?
    role == 'admin'
  end
end
