class UserAnswer < ApplicationRecord
  belongs_to :user
  belongs_to :choice

  validates :user_id, uniqueness: { scope: :choice_id }

  DiagnosisResult = Struct.new(:art_style, :tied_styles, keyword_init: true)

  def self.diagnose!(user:, choice_ids:)
    transaction do
      user.user_answers.destroy_all

      choice_ids.each do |choice_id|
        create!(user:, choice_id:)
      end

      result_style, tied_styles = determine_art_style(choice_ids)

      user.profile.update!(art_style: result_style)

      DiagnosisResult.new(art_style: result_style, tied_styles:)
    end
  end

  def self.determine_art_style(choice_ids)
    scores = ChoiceArtStyle
             .where(choice_id: choice_ids)
             .group(:art_style_id)
             .count

    max_score = scores.values.max
    top_style_ids = scores.select { |_, score| score == max_score }.keys

    if top_style_ids.length > 1
      tied_styles = ArtStyle.where(id: top_style_ids).pluck(:name)
      result_style = ArtStyle.find_by!(name: 'その他')
    else
      tied_styles = []
      result_style = ArtStyle.find(top_style_ids.first)
    end

    [result_style, tied_styles]
  end
  private_class_method :determine_art_style
end
