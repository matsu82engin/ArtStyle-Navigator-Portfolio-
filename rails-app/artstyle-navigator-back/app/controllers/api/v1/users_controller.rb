class Api::V1::UsersController < ApplicationController
  before_action :authenticate_api_v1_user!, except: [:index]
  before_action :set_user, only: [:show, :following, :followers, :following_state]

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

  # GET /api/v1/users/:id/following
  def following
    # フォローしている一覧データをレスポンス
    users = @user.following
    render json: users, status: :ok
  end

  # GET /api/v1/users/:id/followers
  def followers
    # フォローされている一覧データをレスポンス
    users = @user.followers
    render json: users, status: :ok
  end

  # GET /api/v1/users/:id/following_state
  def following_state
    # ログインユーザーは該当ユーザーをフォローしているかどうか
    render json: {
      is_following: current_api_v1_user.following?(@user)
    }
  end

  private

  def set_user
    # params[:id] でユーザーを探す。404 発生時は => application_contoroller の rescue_from
    @user = User.find(params[:id])
  end
end
