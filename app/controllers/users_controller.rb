class UsersController < ApplicationController
  include Pundit

  def show
    @subtitle = Subtitle.new
  end

end
