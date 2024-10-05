module Api
  module V1
    class PicturesController < ApplicationController
      before_action :authenticate_api_v1_user!

      # プロジェクト一覧を返すアクション
      def index
        projects = []
        date = Date.new(2024, 4, 1)
        10.times do |n|
          id = n + 1
          name = "#{current_api_v1_user.name} project #{id.to_s.rjust(2, "0")}"
          updated_at = date + (id * 6).hours
          projects << { id: id, name: name, updatedAt: updated_at }
        end
        # 本来はcurrent_user.projectsで該当ユーザーのプロジェクト一覧を返すものだが簡易的に作成してデモプロジェクトを返すように設定
        render json: projects
      end
    end
  end
end
