module TokenGenerateService
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    # devise_token_auth で access-token のインスタンスから ユーザー情報を取得する
    def find_user_by_token(access_token, client_id, uid)
      user = User.find_by(uid: uid)
      
      if user && user.valid_token?(access_token, client_id)
        return user
      else
        return nil
      end
    end

    # リフレッシュトークンのインスタンス生成
    def decode_refresh_token(token)
      UserAuth::RefreshToken.new(token: token)
    end

    # リフレッシュトークンのuserを返す
    def from_refresh_token(token)
      decode_refresh_token(token).entity_for_user
    end

  end

  ## インスタンスメソッド

  # リフレッシュトークンのインスタンス生成
  def encode_refresh_token
    UserAuth::RefreshToken.new(user_id: id)
  end

  # リフレッシュトークンを返す
  def to_refresh_token
    encode_refresh_token.token
  end

end
