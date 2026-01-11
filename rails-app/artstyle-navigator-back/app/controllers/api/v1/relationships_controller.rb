class Api::V1::RelationshipsController < ApplicationController
  before_action :authenticate_api_v1_user!

  def create
    user = User.find(params[:followed_id])

    # 自分自身をフォローしようとした場合
    if current_api_v1_user.id == user.id
      return render json: { error: '自分自身はフォローできません' },
                    status: :unprocessable_entity
    end

    # すでにフォロー済みの場合
    if current_api_v1_user.following?(user)
      return render json: { error: 'すでにフォローしています' },
                    status: :conflict
    end

    # 正常処理
    if current_api_v1_user.follow(user)
      render json: { success: true }, status: :ok
    else
      render json: { error: 'フォローに失敗しました' }, status: :unprocessable_entity
    end
  end

  def destroy
    user = User.find(params[:id])

    # フォローしてない場合はエラー
    unless current_api_v1_user.following?(user)
      return render json: { error: 'フォローしていません' },
                    status: :unprocessable_entity
    end

    if current_api_v1_user.unfollow(user)
      render json: { success: true }, status: :ok
    else
      render json: { error: 'フォロー解除に失敗しました' }, status: :unprocessable_entity
    end
  end
end
