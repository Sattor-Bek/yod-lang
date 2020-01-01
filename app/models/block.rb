class Block < ApplicationRecord
  belongs_to :subtitle
  has_many :cards, dependent: :destroy
  validates :sentence, presence: true

  def self.as_csv(value)
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
