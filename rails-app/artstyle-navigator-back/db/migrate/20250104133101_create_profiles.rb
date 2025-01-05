class CreateProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :pen_name
      t.references :art_style, null: false, foreign_key: true, index: true
      t.string :art_supply
      t.text :introduction

      t.timestamps
    end
  end
end
