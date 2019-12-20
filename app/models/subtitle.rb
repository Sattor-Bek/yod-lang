class Subtitle < ApplicationRecord
  class MissingSubtitlesError < StandardError; end
  belongs_to :user
  has_many :bloks, dependent: :destroy
  validates :video_id, presence: true
  validates :user, presence: true
  # accepts_nested_attributes_for :blocks
end
