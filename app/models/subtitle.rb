class Subtitle < ApplicationRecord
  class MissingSubtitlesError < StandardError; end
  belongs_to :user
  has_many :blocks, dependent: :destroy
  validates :video_id, presence: true
  validates :user, presence: true
  accepts_nested_attributes_for :blocks

  serialize :language_list, Array
  def to_param
  return self.url_id
  end
end
