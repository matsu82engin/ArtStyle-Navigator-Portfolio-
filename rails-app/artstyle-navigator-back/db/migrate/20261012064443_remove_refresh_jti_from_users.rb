class RemoveRefreshJtiFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :refresh_jti, :string
  end
end
