
class UsersController < ApplicationController
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
end
