class Book < ApplicationRecord
  belongs_to :user
  has_many :cards, dependent: :destroy
  validates :name, presence: true
  validates :user, presence: true
  accepts_nested_attributes_for :cards
end
