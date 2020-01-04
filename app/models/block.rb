class Block < ApplicationRecord
  belongs_to :subtitle
  has_many :cards, dependent: :destroy
  validates :sentence, presence: true

  def self.as_csv(value)
    CSV.generate do |csv|
      column_names = %w(start_timestamp, sentence)
      csv << column_names
      value.sort_by{ |block| block.created_at }.each do |item|
        column_values = [
          item.start_timestamp,
          item.sentence
        ]
        csv << column_values
      end
    end
  end
end
