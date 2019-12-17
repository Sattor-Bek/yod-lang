class CreateBlocks < ActiveRecord::Migration[5.2]
  def change
    create_table :blocks do |t|
      t.text :sentence
      t.datetime :time

      t.timestamps
    end
  end
end
