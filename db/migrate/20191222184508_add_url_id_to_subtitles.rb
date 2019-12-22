class AddUrlIdToSubtitles < ActiveRecord::Migration[5.2]
  def change
    add_column :subtitles, :url_id, :string
  end
end
