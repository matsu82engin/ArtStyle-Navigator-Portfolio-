# class ApplicationController < ActionController::API
#   include DeviseTokenAuth::Concerns::SetUserByToken
#   # skip_before_action :verify_authenticity_token, if: :devise_controller?
# end

class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include ActionController::Cookies
  before_action :configure_permitted_parameters, if: :devise_controller?
  # CSRF対策
  before_action :xhr_request?

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
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
end
