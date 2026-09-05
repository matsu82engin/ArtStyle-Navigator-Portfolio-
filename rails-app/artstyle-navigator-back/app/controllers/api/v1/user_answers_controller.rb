class Api::V1::UserAnswersController < ApplicationController
  before_action :authenticate_api_v1_user!

  def create
    result = UserAnswer.diagnose!(
      user: current_api_v1_user,
      choice_ids: answer_params[:choice_ids]
    )

    render json: {
      art_style: result.art_style.name,
      tied_styles: result.tied_styles
    }, status: :ok
  end

  private

  def answer_params
    params.require(:user_answer).permit(choice_ids: [])
  end
end
