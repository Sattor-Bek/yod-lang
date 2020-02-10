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
    @post = @forum.posts.build(title: posts_params[:title], comment: posts_params[:comment], image:posts_params[:image], user_id: current_user.id)
    if @post.save
      skip_authorization
      redirect_to forum_path(@forum)
    else
      raise
      skip_authorization
      redirect_to forum_path(@forum)
    end
  end

  def edit
  end

  def posts_params
    params.require(:post).permit(:title, :comment, :image)
  end
end
