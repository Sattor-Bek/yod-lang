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

  def self.to_csv(first, second)
    first_block = first.sort_by{ |block| block.created_at }.map.with_index{ |item, i| {first_index: i, first_timestamp: item.start_timestamp.to_s, first_subtitle: item.sentence } }
    second_block = second.sort_by{ |block| block.created_at }.map.with_index{ |item, i|  {second_index: i, second_timestamp: item.start_timestamp.to_s, second_subtitle: item.sentence } }

    if first_block.size > second_block.size
      first_block.each do |first|
        second_block.each do |second|
          first.merge!(second) if first[:first_index] == second[:second_index]
        end
      end
      CSV.generate do |csv|
        column_names = %w(first_timestamp first_subtitle second_timestamp second_subtitle )
        csv << column_names
        first_block.each do |item|
          column_values = [
            item[:first_timestamp],
            item[:first_subtitle],
            item[:second_timestamp],
            item[:second_subtitle]
          ]
          csv << column_values
        end
      end
    else
      second_block.each do |first|
        first_block.each do |second|
          first.merge!(second) if first[:second_index] == second[:first_index]
        end
      end
      CSV.generate do |csv|
        column_names = %w(first_timestamp first_subtitle second_timestamp second_subtitle )
        csv << column_names
        second_block.each do |item|
            column_values = [
              item[:first_timestamp],
              item[:first_subtitle],
              item[:second_timestamp],
              item[:second_subtitle]
             ]
          csv << column_values
        end
      end
    end
  end
end
