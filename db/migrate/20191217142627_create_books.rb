class CreateBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :books do |t|
      t.string :name
      t.integer :book_frequency
      t.boolean :star

      t.timestamps
    end
  end
end
