module TokenGenerateService
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    # devise_token_auth で access-token のインスタンスから ユーザー情報を取得する
    def find_user_by_token(access_token, client_id, uid)
      user = User.find_by(uid:)

      return user if user&.valid_token?(access_token, client_id)

      nil
    end
  end
end
