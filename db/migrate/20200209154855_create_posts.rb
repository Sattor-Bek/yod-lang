class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.references :user, foreign_key: true
      t.references :forum, foreign_key: true
      t.string :title
      t.text :comment
      t.string :image

      t.timestamps
    end
  end
end
