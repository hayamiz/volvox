class AuthorshipsController < ApplicationController
  include DiariesChildrenHelper

  before_filter(:authenticate,
                :only => [:create, :destroy])
  before_filter(:diary_id_exist)
  before_filter(:author_of_diary,
                :only => [:create, :destroy])

  def create
    @user = User.find_by_id(params[:authorship][:user_id])
    if @user
      @authorship = @user.participate(@diary)
      if @authorship
        flash[:success] = "#{@user.name} was successfully added to authors."
        redirect_to edit_diary_path(@diary)
        return
      end
    end
    redirect_to diary_path(@diary)
  end

  private
  def diary_id_exist
    @diary = Diary.find_by_id(params[:authorship][:diary_id])
    unless @diary
      flash[:error] = "No such diary"
      redirect_to root_path
    end
  end
end
