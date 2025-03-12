class AddArtSupplyToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :art_supply, :string
  end
end
