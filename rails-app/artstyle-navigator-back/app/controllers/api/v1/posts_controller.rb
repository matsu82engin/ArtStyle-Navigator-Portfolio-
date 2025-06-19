module Api
  module V1
    class PostsController < ApplicationController
      rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing

      before_action :authenticate_api_v1_user!

      def create
        # post_params を呼ぶ前に、ネストされた属性の形式をチェック
        raw_post_images_attributes = params.dig(:post, :post_images_attributes)

        if raw_post_images_attributes.present? && !raw_post_images_attributes.is_a?(Array)
          render json: { errors: ["post_images_attributes must be an array"] }, status: :bad_request
          return # ここで処理を終了
        end

        # current_api_v1_user を使って Post をビルドするのが一般的です
        post = current_api_v1_user.posts.build(post_params)
        # post.user = current_api_v1_user は build メソッドが自動で行います

        if post.save
          render json: { post: post, post_images: post.post_images }, status: :created
        else
          render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

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
