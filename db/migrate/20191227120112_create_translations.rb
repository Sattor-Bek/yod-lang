class CreateTranslations < ActiveRecord::Migration[5.2]
  def change
    create_table :translations do |t|
      t.string :video_title
      t.string :video_id
      t.string :language
      t.string :url_id
      t.references :subtitle, foreign_key: true

      t.timestamps
    end
  end
end
