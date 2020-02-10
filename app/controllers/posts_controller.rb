class PostsController < ApplicationController
  def show
  end
  
  def new
    @forum = Forum.find(params[:forum_id])
    @post = @forum.posts.build
    skip_authorization
  end

  def create
    @forum = Forum.find(params[:forum_id])
    @post = @forum.posts.build(posts_params)
    if @post.save
      redirect_to forum_path(@forum)
    else
      render forum_path(@forum)
    end
  end

  def edit
  end

  def posts_params
    params.require(:post).permit(:title, :comment, :image, :forum_id)
  end
end
