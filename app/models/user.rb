class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # additional
  has_many :subtitles
  has_many :translations
  has_many :books
  has_many :cards, through: :books
  has_many :forums
  has_many :posts, through: :forums

  # def self.new_guest
  #   new do |u|
  #     u.user_name = "Guest"
  #     u.email    = "guest_#{Time.now.to_i}#{rand(100)}@example.com"
  #     u.password = "aaaaaa"
  #     u.guest    = true
  #   end
  # end

  # def move_to(user)
  #   tasks.update_all(user_id: user.id)
  # end
end
