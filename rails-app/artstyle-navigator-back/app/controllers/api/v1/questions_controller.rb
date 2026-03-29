class Api::V1::QuestionsController < ApplicationController
  def index
    questions = Question.includes(choices: :art_styles)
                        .order(:position)
    render json: questions, include: { choices: { include: :art_styles } }
  end
end
