# rubocop:disable Rails/ApplicationRecord
class User < ActiveRecord::Base
  has_one :profile, dependent: :destroy
  has_many :posts, dependent: :destroy

  devise  :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable

  # token (refresh_token)生成モジュール
  include TokenGenerateService
  include DeviseTokenAuth::Concerns::User
  before_save { self.email = email.downcase }
  # rubocop:enable Rails/ApplicationRecord
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, uniqueness: true, length: { maximum: 255 }
  # パスワード確認のキーがない場合に更新できてしまうことへの対策
  validates :password_confirmation, presence: true, if: -> { password.present? }

  # リフレッシュトークンのJWT IDを保存
  def remember(jti)
    update!(refresh_jti: jti)
  end

  # リフレッシュトークンのJWT IDを削除
  def forget
    update!(refresh_jti: nil)
  end

  # 認可のヘルパーメソッド
  # リソース所有者かどうか
  def owner?
    role == 'owner' || admin?
  end

  # 管理者かどうか
  def admin?
    role == 'admin'
  end
end
