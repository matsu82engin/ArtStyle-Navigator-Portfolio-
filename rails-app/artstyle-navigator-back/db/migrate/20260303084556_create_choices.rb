class CreateChoices < ActiveRecord::Migration[6.1]
  def change
    create_table :choices do |t|
      t.references :question, null: false, foreign_key: true
      t.string :text, null: false
      t.string :label, null: false

      t.timestamps
    end
  end
end
