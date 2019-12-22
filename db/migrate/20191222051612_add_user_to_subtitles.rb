class AddUserToSubtitles < ActiveRecord::Migration[5.2]
  def change
    add_reference :subtitles, :user, foreign_key: true
  end
end
