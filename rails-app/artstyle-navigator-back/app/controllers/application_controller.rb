class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include ActionController::Cookies
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  before_action :configure_permitted_parameters, if: :devise_controller?
  # CSRF対策
  before_action :xhr_request?

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(
      :account_update,
      keys: [
        :name,
        :email,
        :password,
        :password_confirmation,
        :current_password
      ]
    )
  end

  # ユーザーが見つからない場合に 404(not_found)とメッセージを返す
  def render_not_found(message = 'Not Found')
    render json: { error: message }, status: :not_found
  end

  private

  # XMLHttpRequestでない場合は403エラーを返す(CSRF 対策)
  def xhr_request?
    # リクエストヘッダ X-Requested-With: 'XMLHttpRequest' の存在を判定
    return true if request.xhr?

    render status: :forbidden, json: { status: 403, error: 'Forbidden' }
    false
  end

  # Internal Server Error
  def internal_server_error_response(msg = 'Internal Server Error')
    render status: :internal_server_error, json: { status: 500, error: msg }
  end

  # 認可チェック(authorize_owner! は必要ないが拡張性を考えて書いておく)
  def authorize_owner!
    # userモデルに定義したメソッドを呼び出す
    return if current_api_v1_user.owner? # owner であれば true を返して下のコードにはいかない

    render json: { error: '権限がありません' }, status: :forbidden
  end

  # 管理者権限チェック
  def authorize_admin!
    return if current_api_v1_user.admin?

    render json: { error: '管理者権限が必要です' }, status: :forbidden
  end
end
