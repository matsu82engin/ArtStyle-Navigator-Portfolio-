class AddArtStyleToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :art_style, :string
  end
end
