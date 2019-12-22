class AddStartTimeStampToBlocks < ActiveRecord::Migration[5.2]
  def change
    add_column :blocks, :start_timestamp, :string
  end
end
