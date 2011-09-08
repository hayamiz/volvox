
class DiariesController < ApplicationController
  before_filter :authenticate
  before_filter :author, :only => [:edit, :update]

  def new
    @title = "Create a new diary"
    @diary = Diary.new
  end

  def create
    @diary = Diary.new(params[:diary])
    if @diary.valid?
      ActiveRecord::Base::transaction do
        @diary.save!
        current_user.participate(@diary)
      end
      redirect_to root_path
    else
      render "diaries/new"
    end
  end

  def edit
    @title = "Edit the diary"
  end

  def update
    if @diary.update_attributes(params[:diary])
      flash[:notice] = "Updated the diary settings."
      redirect_to diaries_path(@diary)
    else
      render "diaries/edit"
    end
  end

private
  def author
    @diary = Diary.find_by_id(params[:id])
    redirect_back_or signin_path unless current_user.author?(@diary)
  end
end
