class CreateCards < ActiveRecord::Migration[5.2]
  def change
    create_table :cards do |t|
      t.text :phrase
      t.text :phrase_translated
      t.boolean :memorized
      t.boolean :bookmark
      t.integer :view_count
      t.integer :card_frequency

      t.timestamps
    end
  end
end
