class Block < ApplicationRecord
  belongs_to :subtitle
  has_many :cards, dependent: :destroy
  validates :sentence, presence: true
  validates :subtitle, presence: true
end
