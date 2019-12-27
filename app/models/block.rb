class Block < ApplicationRecord
  belongs_to :subtitle , :as => :user
  belongs_to :translation
  has_many :cards, dependent: :destroy
  validates :sentence, presence: true
end
