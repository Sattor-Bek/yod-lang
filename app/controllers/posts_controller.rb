class PostsController < ApplicationController
  def show
  end

  def create
    post = Post.new(title: post_params[:title], comment: post_params[:comment], image: post_params[:image], user_id:current_user.id, forum_id:post_params[:id])
    post.save
    skip_authorization
    redirect_to posts_path
  end
  
  def new
    
  end

  def edit
  end

  def posts_params
    params.require(:posts).permit(:title, :comment, :image, :id)
  end
end
