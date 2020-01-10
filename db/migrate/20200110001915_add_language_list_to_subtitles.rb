class AddLanguageListToSubtitles < ActiveRecord::Migration[5.2]
  def change
    add_column :subtitles, :language_list, :text, array: true
  end
end
