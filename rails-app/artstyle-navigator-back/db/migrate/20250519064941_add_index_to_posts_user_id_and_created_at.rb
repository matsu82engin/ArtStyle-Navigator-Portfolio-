class AddIndexToPostsUserIdAndCreatedAt < ActiveRecord::Migration[6.1]
  def change
    # user_id と created_at の複合インデックスを追加
    add_index :posts, [:user_id, :created_at]

    # created_at 単独のインデックスを追加
    add_index :posts, :created_at
  end
end
