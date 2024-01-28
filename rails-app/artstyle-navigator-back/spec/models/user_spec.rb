require 'rails_helper'

# RSpec.describe User do にしてもOK
RSpec.describe User, type: :model do
  # 有効なユーザーの作成のテスト
  describe 'valid user create' do
    # 正しいユーザーが作成されるかをテスト
    context 'when the user is valid' do
      # let(:user) { FactoryBot.build(:user) }
      let(:user) { build(:user) }

      # 正しい名前とアドレス、パスワードとパスワード確認があれば作成される
      it 'is created with a valid name, email, password, and password_confirmation' do
        expect(user).to be_valid
      end
    end
  end

  # 異常系のテスト
  describe 'invalid user test' do
    # 名前とアドレスが有効でない場合のテスト
    context 'when the name and address are not valid' do
      let(:user) { build(:user) }

      # 名前が空白の場合は無効
      it 'is invalid if the name is blank' do
        user.name = nil
        expect(user).not_to be_valid
      end

      # アドレスが空白の場合は無効
      it 'is invalid if the address is blank' do
        user.email = nil
        expect(user).not_to be_valid
      end
    end

    # 名前とアドレスが長すぎれば無効
    context 'when the name and address are too long' do
      let(:user) { build(:user) }

      # 名前が長すぎる場合は無効
      it 'is invalid if the name is too long' do
        user.name = 'a' * 51 # 51 文字以上は無効
        expect(user).not_to be_valid
      end

      # アドレスが長すぎる場合は無効
      it 'is invalid if the address is too long' do
        user.email = "#{'a' * 244}@example.com"
        expect(user).not_to be_valid
      end
    end

    # メールのフォーマットを検証
    context 'when validating the format of the email' do
      let(:user) { build(:user) }

      # 有効なアドレスを受け入れる
      it 'is accepts a valid address' do
        valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
        valid_addresses.each do |valid_address|
          user.email = valid_address
          expect(user).to be_valid, "#{valid_address.inspect} should be valid"
        end
      end

      # 無効なアドレスは拒否
      it 'is rejects an invalid address' do
        invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
        invalid_addresses.each do |invalid_address|
          user.email = invalid_address
          expect(user).not_to be_valid, "#{invalid_address.inspect} should be invalid"
        end
      end

      # 重複するメールアドレスを拒否
      it 'is email addresses should be unique' do
        duplicate_user = user.dup
        user.save
        expect(duplicate_user).not_to be_valid
      end
    end

    # 無効なパスワードとパスワード確認の検証
    context 'with invalid password and password confirmation' do
      let(:user) { build(:user) }

      # パスワードが空白の場合は無効
      it 'is invalid if the password is blank' do
        user.password = nil
        expect(user).not_to be_valid
      end

      # パスワードが5文字以下の場合は無効
      it 'is invalid with a too short password' do
        user.password = user.password_confirmation = 'short'
        expect(user).not_to be_valid
      end

      # パスワードが6文字以上だが空白の場合は無効
      it 'is invalid when the password is 6 characters or more but blank' do
        user.password = user.password_confirmation = '' * 6
        expect(user).not_to be_valid
      end

      # パスワードとパスワード確認が一致しない場合は無効
      it 'is invalid when password confirmation does not match' do
        user.password_confirmation = 'mismatched_password'
        expect(user).not_to be_valid
      end
    end
  end
end
