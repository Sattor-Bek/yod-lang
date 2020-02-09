class ForumsController < ApplicationController
  def index
    authorize_forum
    @forums = Forum.all
  end

  def show
    authorize_forum
    @forum = Forum.find(params[:id])
    @posts = Post.find_by(forum_id: params[:forum.id])
  end

  def new
    @forum = Forum.new
  end

  def create
    Forum.create(forum_params)
  end

  def edit
    authorize_forum
    # edit should be permitted only for admin or user
  end

  def update
    authorize_forum
  end

  def forum_params
    params.require(:forum).permit(:title, :user_id, :updated_at)
  end
end
