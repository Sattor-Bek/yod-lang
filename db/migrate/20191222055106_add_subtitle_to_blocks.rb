class AddSubtitleToBlocks < ActiveRecord::Migration[5.2]
  def change
    add_reference :blocks, :subtitle, foreign_key: true
  end
end
