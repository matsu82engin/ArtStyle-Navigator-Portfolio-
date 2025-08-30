class CreatePostImages < ActiveRecord::Migration[6.1]
  def change
    create_table :post_images do |t|
      t.references :post, null: false, foreign_key: true
      t.references :art_style, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
      t.string :caption, limit: 1000, null: true
      t.text :tips, null: true
      t.string :alt, null: true

      t.timestamps
    end

    add_index :post_images, [:post_id, :position], unique: true
    add_index :post_images, [:art_style_id, :created_at]
  end
end
