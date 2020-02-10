class AddImageToForum < ActiveRecord::Migration[5.2]
  def change
    add_column :forums, :image, :string
  end
end
