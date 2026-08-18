class Api::V1::AllPostsController < ApplicationController
  before_action :authenticate_api_v1_user!

  def index
    posts = Post
            .includes(
              post_images: [
                :art_style,
                { image_attachment: :blob }
              ]
            )
            .order(created_at: :desc)

    if params[:art_style_id].present?
      posts = posts.joins(:post_images)
                   .where(post_images: { art_style_id: params[:art_style_id] })
                   .distinct # 将来の柔軟性のために入れておく
    end

    render json: posts.map { |post|
      post.as_json(
        only: [:id, :title, :user_id, :created_at],
        include: {
          post_images: {
            only: [:id, :caption, :position],
            methods: [:image_url],
            include: {
              art_style: { only: [:id, :name] }
            }
          }
        }
      )
    }, status: :ok
  end
end
