class Api::V1::UsersController < ApplicationController
  before_action :authenticate_api_v1_auth_user!, except: [:index]

  # GET /api/v1/users/:id
  def show
    render json: current_api_v1_auth_user
  end

  # GET /api/v1/users
  def index
    users = User.all
    render json: users.as_json(only: [:id, :name, :email, :created_at])
  end
end
