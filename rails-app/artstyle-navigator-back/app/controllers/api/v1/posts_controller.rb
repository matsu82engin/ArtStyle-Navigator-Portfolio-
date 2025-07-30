module Api
  module V1
    class PostsController < ApplicationController
      rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
      before_action :authenticate_api_v1_user!
      before_action :set_post, only: [:destroy]

      # /api/v1/posts
      def index
        # とりあえず投稿は確認OK
        # posts = current_api_v1_user.posts.latest
        # render json: posts, status: :ok

        posts = current_api_v1_user.posts
                                   .includes(post_images: :art_style)
                                   .latest

        render json: posts.map { |post|
          post.as_json(
            only: [:id, :title, :created_at],
            include: {
              post_images: {
                only: [:id, :caption, :position],
                include: {
                  art_style: { only: [:id, :name] }
                }
              }
            }
          )
        }, status: :ok
      end

      def create
        # post_params を呼ぶ前に、ネストされた属性の形式をチェック
        raw_post_images_attributes = params.dig(:post, :post_images_attributes)

        if raw_post_images_attributes.present? && !raw_post_images_attributes.is_a?(Array)
          render json: { errors: ['post_images_attributes must be an array'] }, status: :bad_request
          return # ここで処理を終了
        end

        # current_api_v1_user を使って Post をビルドするのが一般的です
        post = current_api_v1_user.posts.build(post_params)
        # post.user = current_api_v1_user は build メソッドが自動で行います

        if post.save
          render json: { post:, post_images: post.post_images }, status: :created
        else
          render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if @post.user_id == current_api_v1_user.id
          @post.destroy
          head :no_content
        else
          render json: { error: '削除権限がありません' }, status: :forbidden
        end
      end

      private

      def set_post
        @post = Post.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: '投稿が見つかりません' }, status: :not_found
      end

      def handle_parameter_missing(exception)
        render json: { error: "Required parameter missing: #{exception.param}" }, status: :bad_request
      end

      def post_params
        params.require(:post).permit(
          :title,
          post_images_attributes: [
            :id, # 更新や既存レコードの指定のためにidも許可リストに入れるのが一般的
            :art_style_id,
            :position,
            :caption,
            :tips,
            :alt,
            :_destroy # ネストされたレコードの削除を許可する場合
          ]
        )
      end
    end
  end
end
