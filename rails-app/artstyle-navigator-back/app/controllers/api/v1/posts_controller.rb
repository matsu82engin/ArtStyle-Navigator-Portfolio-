module Api
  module V1
    class PostsController < ApplicationController
      rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
      before_action :authenticate_api_v1_user!
      before_action :set_post, only: [:destroy]
      # createアクションの権限チェックを before_action に切り出す
      before_action :authorize_user_for_creation!, only: [:create]

      # /api/v1/posts
      def index
        # users/:user_id/posts なので user_id に ユーザーオブジェクトの主キー(id)が入っている。よってそれで find をかける。
        user = User.find(params[:user_id])
        # ユーザーに紐づいている投稿を便利メソッドから取得
        posts = user.posts
                    .includes(post_images: :art_style)
                    .latest

        render json: posts.map { |post|
          post.as_json(
            only: [:id, :title, :created_at],
            include: {
              post_images: {
                only: [:id, :caption, :position],
                methods: [:image_url], # 画像のURLをレスポンス
                include: {
                  art_style: { only: [:id, :name] }
                }
              }
            }
          )
        }, status: :ok
      end

      def create
        # current_api_v1_user を使って Post をビルドするのが一般的
        post = current_api_v1_user.posts.build(post_params)

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

      # create アクション用の権限チェックメソッド
      def authorize_user_for_creation!
        # URL の user_id がログインユーザーの id と一致しない場合、403 を返す
        render json: { error: '権限がありません' }, status: :forbidden if params[:user_id].to_s != current_api_v1_user.id.to_s
      end

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
            :image,
            :_destroy # ネストされたレコードの削除を許可する場合
          ]
        )
      end
    end
  end
end
