class AddTranslationToBlocks < ActiveRecord::Migration[5.2]
  def change
    add_reference :blocks, :translation, foreign_key: true
  end
end
