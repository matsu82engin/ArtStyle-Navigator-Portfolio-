class PostImage < ApplicationRecord
  belongs_to :post
  belongs_to :art_style

  before_validation :set_alt_from_caption
  before_validation :strip_whitespace

  # ここからカラムのバリデーション
  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 },
            uniqueness: { scope: :post_id } # 複合ユニーク

  validates :caption,
            length: { maximum: 1000 }, allow_blank: true

  # tips は今のところバリデーションはいらない。
  # nil (未入力)は許可し空白のみ弾きたいが、フォームの挙動によって自動的に空白になるので、
  # 空白のみに投稿は strip_whitespace で消され、結果的に複数空白のない入力、つまり未入力のみを許可した状態になるから。

  private

  def set_alt_from_caption
    # もし caption に値があり、alt が空の場合に値をコピーする
    # これにより、将来的にaltだけを個別に設定したくなった場合にも対応できる
    self.alt = self.caption if self.caption.present? && self.alt.blank?
  end

  def strip_whitespace
    # 最初と最後に半角空白があれば(複数も)削除して保存
    # self.caption = self.caption.strip if self.caption.present?
    # 最初と最後に全角空白があれば(複数も)削除して保存
    self.caption&.gsub!(/\A[\s　]+|[\s　]+\z/, "")
    self.tips&.gsub!(/\A[\s　]+|[\s　]+\z/, "")
    self.alt&.gsub!(/\A[\s　]+|[\s　]+\z/, "")
  end
end
