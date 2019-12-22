class AddBlockAndBookToCards < ActiveRecord::Migration[5.2]
  def change
    add_reference :cards, :block, foreign_key: true
    add_reference :cards, :book, foreign_key: true
  end
end
