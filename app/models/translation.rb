class Translation < ApplicationRecord
  class MissingSubtitlesError < StandardError; end
  belongs_to :user
  has_many :blocks, dependent: :destroy, through: :subtitles
  validates :video_id, presence: true
  validates :user, presence: true
  accepts_nested_attributes_for :blocks

  def to_param
  return self.url_id
  end

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |item|
        csv << item.attributes.values_at(*column_names)
      end
    end
  end
end
