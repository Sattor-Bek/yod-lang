class Block < ApplicationRecord
  belongs_to :subtitle
  has_many :cards, dependent: :destroy
  validates :sentence, presence: true

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |block|
        csv << block.attributes.values_at(*column_names)
      end
    end
  end
end
