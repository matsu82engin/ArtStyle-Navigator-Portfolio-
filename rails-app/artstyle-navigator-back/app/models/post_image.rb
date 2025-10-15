class PostImage < ApplicationRecord
  belongs_to :post
  belongs_to :art_style

  has_one_attached :image

  # RailsのURLヘルパーを使えるようにするためのおまじない
  include Rails.application.routes.url_helpers

  before_validation :set_alt_from_caption
  before_validation :strip_whitespace

  # ここからカラムのバリデーション
  validate :image_attached
  # validates :image, presence: true
  validate :validate_image

  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 },
            uniqueness: { scope: :post_id } # 複合ユニーク

  validates :caption,
            length: { maximum: 1000 }, allow_blank: true

  # tips は今のところバリデーションはいらない。
  # nil (未入力)は許可し空白のみ弾きたいが、フォームの挙動によって自動的に空白になるので、
  # 空白のみに投稿は strip_whitespace で消され、結果的に複数空白のない入力、つまり未入力のみを許可した状態になるから。

  # 画像のURLを返すためのカスタムメソッド
  def image_url
    # imageが添付されているかを確認し、添付されていればURLを生成して返す
    # (image.attached? がないと、画像がない場合にエラーになる)
    image.attached? ? url_for(image) : nil
  end

  private
  
  def image_attached
    errors.add(:image, 'を添付してください') unless image.attached?
  end

  # active_storage_validations gem を使うと簡単にバリデーションが書けるが自作してみる
  def validate_image
    return unless image.attached?
  
    # MIMEタイプのチェック
    unless image.content_type.in?(%w(image/png image/jpg image/jpeg))
      errors.add(:image, 'はPNGまたはJPEG形式でアップロードしてください')
    end
  
    # ファイルサイズのチェック
    if image.byte_size > 5.megabytes
      errors.add(:image, 'は5MB以下にしてください')
    end
  end

  def set_alt_from_caption
    # もし caption に値があり、alt が空の場合に値をコピーする
    # これにより、将来的にaltだけを個別に設定したくなった場合にも対応できる
    self.alt = caption if caption.present? && alt.blank?
  end

  def strip_whitespace
    # 最初と最後に半角空白があれば(複数も)削除して保存
    # self.caption = self.caption.strip if self.caption.present?
    # 最初と最後に全角空白があれば(複数も)削除して保存
    caption&.gsub!(/\A[\s　]+|[\s　]+\z/, '')
    tips&.gsub!(/\A[\s　]+|[\s　]+\z/, '')
    alt&.gsub!(/\A[\s　]+|[\s　]+\z/, '')
  end
end
