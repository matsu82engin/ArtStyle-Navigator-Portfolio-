class Api::V1::UsersController < ApplicationController
  before_action :authenticate_api_v1_user!, except: [:index]
  before_action :set_user, only: [:show, :following, :followers, :following_state, :following_posts]

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
    users = @user.following.includes(:profile)
    render json: users.map { |user| user_with_profile_json(user) }, status: :ok
  end

  # GET /api/v1/users/:id/followers
  def followers
    # フォローされている一覧データをレスポンス
    users = @user.followers.includes(:profile)
    render json: users.map { |user| user_with_profile_json(user) }, status: :ok
  end

  # GET /api/v1/users/:id/following_state
  def following_state
    # ログインユーザーは該当ユーザーをフォローしているかどうか
    render json: {
      is_following: current_api_v1_user.following?(@user)
    }
  end

  def following_posts
    following_user_ids = @user.following.pluck(:id)

    posts = Post.where(user_id: following_user_ids)
                .includes(post_images: { image_attachment: :blob })
                .order(created_at: :desc)

    render json: posts.map { |post| following_post_json(post) }, status: :ok
  end

  private

  def set_user
    # params[:id] でユーザーを探す。404 発生時は => application_contoroller の rescue_from
    @user = User.find(params[:id])
  end

  def user_with_profile_json(user)
    profile = user.profile
    {
      id: user.id,
      pen_name: profile&.pen_name,
      introduction: profile&.introduction,
      avatar_url: profile&.avatar_url
    }
  end

  def following_post_json(post)
    {
      id: post.id,
      title: post.title,
      user_id: post.user_id,
      post_images: post.post_images.map do |image|
        {
          id: image.id,
          image_url: image.image_url,
          caption: image.caption
        }
      end
    }
  end
end
