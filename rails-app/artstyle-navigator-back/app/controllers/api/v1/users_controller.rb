class Api::V1::UsersController < ApplicationController
  before_action :authenticate_api_v1_user!, except: [:index]
  before_action :set_user, only: [:show]

  # GET /api/v1/users
  def index
    users = User.all
    render json: users.as_json(only: [:id, :name, :email, :created_at])
  end

  # GET /api/v1/users/:id
  def show
    # render json: current_api_v1_user
    # 必要なユーザーデータのみレスポンスする
    render json: @user.as_json(only: [:id, :name, :email, :created_at])
  end

  private

  def set_user
    # params[:id] でユーザーを探す。404 発生時は => application_contoroller の rescue_from
    @user = User.find(params[:id])
  end
end
