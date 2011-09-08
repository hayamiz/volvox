
class DiariesController < ApplicationController
  before_filter :authenticate

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
end
