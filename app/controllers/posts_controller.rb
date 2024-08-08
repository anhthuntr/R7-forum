class PostsController < ApplicationController
  before_action :check_logon, except: %w[show]
  before_action :set_forum, only: %w[create new]
  before_action :set_post, only: %w[show edit update destroy]
  before_action :check_access, only: %w[edit update delete] #access control!! a user can only edit or update or delete their own posts
  def create
    @post = @forum.posts.new(post_params) #create a new post for the current forum
    if @post.save
      redirect_to @post, notice: "Your post was created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def new
    @post = @forum.posts.new
  end

  def edit
  end

  def show
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Your post was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @forum = @post.forum #need to save this, so we can redirect to the forum after destroy
    @post.destroy
    redirect_to @forum, notice: "Your post was deleted."
  end

  private
  def check_logon
    if !@current_user
      redirect_to forums_path, notice: "You can't add, modify, or delete posts before logon."
    end
  end

  def set_forum
    @forum = Forum.find(params[:forum_id])
    # if check the routes for posts, see that this is the forum parameter
  end

  def set_post 
    @post = Post.find(params[:id])
  end

  def check_access 
    if @post.user_id != session[:current_user]
      redirect_to forums_path, notice: "That's not your post, you can't change it."
    end
  end

  def post_params #security check, known as "strong parameters"
    params[:post][:user_id] = session[:current_user]
    #have to add a parameter so that the post is associated with the current user
    params.require(:post).permit(:title, :content, :user_id)
  end
end
