class Subtitle < ApplicationRecord
  class MissingSubtitlesError < StandardError; end
  belongs_to :user
  has_many :blocks, dependent: :destroy
  validates :video_id, presence: true
  validates :user, presence: true
  accepts_nested_attributes_for :blocks

  def to_param
  return self.url_id
  end

  def to_csv(value)
    CSV.generate do |csv|
      column_names = %w(start_timestamp, sentence, created_at, updated_at)
      csv << column_names
      value.each do |item|
        column_values = [
          item.start_timestamp,
          item.sentence,
          item.created_at,
          item.updated_at
        ]
        csv << column_values
      end
    end
  end
end
