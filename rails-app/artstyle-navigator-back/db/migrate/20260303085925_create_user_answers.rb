class CreateUserAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :user_answers do |t|
      t.references :user, null: false, foreign_key: true
      t.references :choice, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_answers, [:user_id, :choice_id], unique: true
  end
end
