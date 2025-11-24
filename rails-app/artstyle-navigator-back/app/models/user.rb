class User < ApplicationRecord
  has_one :profile, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :active_relationships, class_name: 'Relationship',
                                  foreign_key: 'follower_id',
                                  inverse_of: :follower,
                                  dependent: :destroy

  has_many :passive_relationships, class_name: 'Relationship',
                                   foreign_key: 'followed_id',
                                   inverse_of: :followed,
                                   dependent: :destroy

  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  # has_many :followers, through: :passive_relationships でも可

  devise  :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable

  # token (refresh_token)生成モジュール
  include TokenGenerateService
  include DeviseTokenAuth::Concerns::User
  before_save { self.email = email.downcase }

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

  # ユーザーをフォローする
  def follow(other_user)
    following << other_user
  end

  # ユーザーのフォローを解除
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # 現在のユーザーが other_user をフォローしていれば true
  def following?(other_user)
    following.include?(other_user)
  end
end
