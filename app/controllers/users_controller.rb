
class UsersController < ApplicationController
  before_filter :authenticate, :only => [:edit, :update]
  before_filter :correct_user, :only => [:edit, :update]

  def new
    @title = t('users.new.title')
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
    if @user.nil?
      not_found
      return
    end
    @diaries = @user.diaries.paginate(:page => params[:page])

    # diaries to which current user can invite @user
    @diaries_for_invite = nil
    if signed_in?
      @diaries_for_invite = current_user.diaries.select do |diary|
        ! @user.author?(diary)
      end
      @diaries_for_invite = nil if @diaries_for_invite.empty?
    end
  end

  def edit
    @title = t'users.edit.title'
  end

  def update
    @user = User.find_by_id(params[:id])
    attr = params[:user]
    if attr[:password].empty? && attr[:password_confirmation].empty?
      attr.delete(:password)
      attr.delete(:password_confirmation)
    end

    if @user.update_attributes(params[:user])
      flash[:success] = t('users.update.flash.success')
      redirect_to @user
    else
      @title = t'users.edit.title'
      render 'edit'
    end
  end

  private
  def correct_user
    @user = User.find_by_id(params[:id])
    redirect_to root_path unless @user == current_user
  end
end
