class AddRoleToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :role, :string, default: 'owner', null: false
  end
end
