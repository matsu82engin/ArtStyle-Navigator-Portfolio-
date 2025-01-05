class CreateArtStyles < ActiveRecord::Migration[6.1]
  def change
    create_table :art_styles do |t|
      t.string :name, null:false
      t.string :description
      t.string :thumbnail_url

      t.timestamps
    end

    add_index :art_styles, :name, unique: true
  end
end
