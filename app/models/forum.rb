class Forum < ApplicationRecord
  belongs_to :user
  has_many :posts
  accepts_nested_attributes_for :posts
end
