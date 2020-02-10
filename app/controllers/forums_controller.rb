class ForumsController < ApplicationController
  skip_after_action :verify_policy_scoped, :only => :index
  def index
    @forums = Forum.all
  end

  def show
    @forum = Forum.find(params[:id])
    @posts = Post.where(forum_id: params[:id]) 
    @post = Post.new(user_id:current_user.id, forum_id:params[:id])
    @post.save
    skip_authorization
  end

  def new
    @forum = Forum.new
    skip_authorization
  end

  def create
    forum = Forum.new(title: forum_params[:title], comment: forum_params[:comment], image: forum_params[:image], user_id:current_user.id)
    forum.save
    skip_authorization
    redirect_to forums_path
  end

  def edit
    authorize_forum
    # edit should be permitted only for admin or user
  end

  def update
    authorize_forum
  end

  def forum_params
    params.require(:forum).permit(:title, :comment, :image)
  end
end
