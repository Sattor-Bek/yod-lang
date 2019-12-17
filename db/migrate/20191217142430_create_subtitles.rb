class CreateSubtitles < ActiveRecord::Migration[5.2]
  def change
    create_table :subtitles do |t|
      t.string :video_title
      t.string :video_id
      t.string :language

      t.timestamps
    end
  end
end
