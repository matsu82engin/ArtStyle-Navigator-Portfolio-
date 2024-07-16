require 'rails_helper'

RSpec.describe 'RefreshToken', type: :request do
  let(:user) { create(:user) }
  let(:encode) { UserAuth::RefreshToken.new(user_id: user.id) }
  let(:decode) { UserAuth::RefreshToken.new(token: encode.token) }
  let(:lifetime) { UserAuth.refresh_token_lifetime }
  let(:payload) { encode.payload }

  before do
    user
    encode
    lifetime
  end

  # エンコード
  describe 'encode_token' do
    it 'encodes the token with expected payload' do
      # payload[:exp]の値は想定通りか(1秒許容)
      expect_lifetime = lifetime.from_now.to_i
      expect(payload[:exp]).to be_within(1.second).of(expect_lifetime)
    end

    it 'encodes the token with expected jti payload' do
      encode_user = encode.entity_for_user
      expect_jti = encode_user.refresh_jti
      expect(payload[:jti]).to eq(expect_jti)
    end

    it 'encodes the token with expected user claim payload' do
      user_claim = encode.send(:user_claim)
      expect(payload[user_claim]).to eq(encode.user_id)
    end
  end

  describe 'decode_token' do
    it 'decodes the token and verifies the user' do
      token_user = decode.entity_for_user
      expect(token_user).to eq(user)
    end

    it 'verifies the claims in the token' do
      verify_claims = decode.send(:verify_claims)
      expect(verify_claims[:verify_expiration]).to be_truthy
      expect(verify_claims[:algorithm]).to eq(UserAuth.token_signature_algorithm)
    end

    it 'raises error for expired token' do
      travel_to(lifetime.from_now) do
        expect do
          UserAuth::RefreshToken.new(token: encode.token)
        end.to raise_error(JWT::ExpiredSignature)
      end
    end

    it 'raises error for invalid token' do
      invalid_token = "#{encode.token}a"
      expect do
        UserAuth::RefreshToken.new(token: invalid_token)
      end.to raise_error(JWT::VerificationError)
    end
  end

  describe 'verify_claims' do
    before do
      user.reload
    end

    it 'verifies the claims in the token' do
      expect(user.refresh_jti).to eq(payload[:jti])
      expect do
        UserAuth::RefreshToken.new(token: encode.token)
      end.not_to raise_error
    end

    it 'raises error for invalid jti' do
      user.remember('invalid')
      expect do
        UserAuth::RefreshToken.new(token: encode.token)
      end.to raise_error(JWT::InvalidJtiError, 'Invalid jti')
    end

    it 'raises error for forgotten user' do
      user.forget
      user.reload
      expect(user.reload.refresh_jti).to be_nil
      expect do
        UserAuth::RefreshToken.new(token: encode.token)
      end.to raise_error(JWT::InvalidJtiError)
    end
  end
end
