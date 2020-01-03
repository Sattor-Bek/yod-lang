class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :guest]

  def home
    @subtitle = Subtitle.new
  end

  def guest
    guest = create_guest_user
    session[:current_user_id] = guest.id
    redirect_to(root_url)
  end

end
