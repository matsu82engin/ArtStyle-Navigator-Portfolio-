class CreateChoiceArtStyles < ActiveRecord::Migration[6.1]
  def change
    create_table :choice_art_styles do |t|
      t.references :choice, null: false, foreign_key: true
      t.references :art_style, null: false, foreign_key: true

      t.timestamps
    end

    add_index :choice_art_styles, [:choice_id, :art_style_id], unique: true
  end
end
