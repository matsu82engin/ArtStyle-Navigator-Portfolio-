class ChangePenNameNotNullToProfiles < ActiveRecord::Migration[6.1]
  def change
    change_column :profiles, :pen_name, :string, null: false
  end
end
