class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :guest, :new_guest]

  def home
    @date = DateTime.now
    @subtitle = Subtitle.new
  end

  def guest
    guest = create_guest_user
    session[:current_user_id] = guest.id
    redirect_to root_path
  end

  def new_guest
    user = User.find_or_create_by!( user_name: "Guest", email: "guest_#{Time.now.to_i}#{rand(100)}@example.com", guest: true, admin: false) do |user|
      user.password = SecureRandom.urlsafe_base64
    end
    sign_in user
    redirect_to root_path, notice: 'ゲストユーザーとしてログインしました。'
  end
end
