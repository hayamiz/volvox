
class UsersController < ApplicationController
  before_filter :authenticate, :only => [:edit, :update]
  before_filter :correct_user, :only => [:edit, :update]

  def new
    @title = "Sign up"
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to @user
    else
      render "users/new"
    end
  end

  def show
    @user = User.find_by_id(params[:id])
    not_found unless @user
  end

  def edit
    @title = "Setting"
  end

  def update
    @user = User.find_by_id(params[:id])
    attr = params[:user]
    if attr[:password].empty? && attr[:password_confirmation].empty?
      attr.delete(:password)
      attr.delete(:password_confirmation)
    end

    if @user.update_attributes(params[:user])
      flash[:success] = "Updated your profile."
      redirect_to @user
    else
      @title = "Setting"
      render 'edit'
    end
  end

  private
  def correct_user
    @user = User.find_by_id(params[:id])
    redirect_to root_path unless @user == current_user
  end
end
