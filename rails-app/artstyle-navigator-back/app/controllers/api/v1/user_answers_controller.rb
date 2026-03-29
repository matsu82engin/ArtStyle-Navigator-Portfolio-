class Api::V1::UserAnswersController < ApplicationController
  before_action :authenticate_api_v1_user!

  def create
    # 既存の回答を先に削除
    UserAnswer.where(user: current_api_v1_user).destroy_all

    answers = answer_params[:choice_ids].map do |choice_id|
      UserAnswer.find_or_create_by!(
        user: current_api_v1_user,
        choice_id:
      )
    end

    # スコア集計
    choice_ids = answers.map(&:choice_id)

    scores = ChoiceArtStyle
             .where(choice_id: choice_ids)
             .group(:art_style_id)
             .count

    # 同点チェック
    max_score = scores.values.max
    top_style_ids = scores.select { |_, score| score == max_score }.keys

    if top_style_ids.length > 1
      # 同点の場合
      tied_styles = ArtStyle.where(id: top_style_ids).pluck(:name)
      result_style = ArtStyle.find_by!(name: 'その他')
    else
      # 1位が決まった場合
      tied_styles = []
      result_style = ArtStyle.find(top_style_ids.first)
    end

    # Profileに結果を保存
    current_api_v1_user.profile.update!(art_style: result_style)

    # フロントに返す
    render json: {
      art_style: result_style.name,
      tied_styles:
    }, status: :ok
  end

  private

  def answer_params
    params.require(:user_answer).permit(choice_ids: [])
  end
end
