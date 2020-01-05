class Card < ApplicationRecord
  belongs_to :block
  belongs_to :book, counter_cache: true
  accepts_nested_attributes_for :block

end
