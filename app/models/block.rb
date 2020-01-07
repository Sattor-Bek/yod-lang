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
    original = first.sort_by{ |block| block.created_at }.map.with_index{ |item, i| {first_index: i, first_timestamp: item.start_timestamp.to_s, first_subtitle: item.sentence } }
    to_add = second.sort_by{ |block| block.created_at }.map.with_index{ |item, i|  {second_index: i, second_timestamp: item.start_timestamp.to_s, second_subtitle: item.sentence } }
    original.append(to_add).flatten!

    CSV.generate do |csv|
      column_names = %w(first_timestamp first_subtitle second_timestamp second_subtitle )
      csv << column_names
      original.each do |item|
        if item[:first_timestamp] != nil
          column_values = [
            item[:first_timestamp],
            item[:first_subtitle].
            nil,
            nil
          ]
        else
          # column_values.each do |row|
          #   if row[2] = nil
          #     row[2] = item[:second_timestamp]
          #     row[3] = item[:second_subtitle]
          #   elsif
          #   end
          # end
        end
        csv << column_values
      raise
      # if the first block is bigger
      # put "second" at first with nils and "first" to replace nil (overwrite)
      # if the second block is bigger
      # put "first" at first with nils and "second" to replace nil (over write)

    end
  end
end
