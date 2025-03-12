class RemoveArtStyleAndSupplyFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :art_style, :string
    remove_column :users, :art_supply, :string
  end
end
