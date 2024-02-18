class Api::V1::UsersController < ApplicationController
  before_action :authenticate_api_v1_auth_user!

  # GET /api/v1/users/:id
  def show
    render json: current_api_v1_auth_user
  end
end
