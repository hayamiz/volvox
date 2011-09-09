class EntriesController < ApplicationController
  before_filter :authenticate, :only => [:new, :edit, :create, :update]
  before_filter :diary_exist
  before_filter :author_of_diary, :only => [:new, :edit, :create, :update]

  def new
    @entry = Entry.new
    @title = "New entry"
  end

  def create
    @entry = @diary.entries.build(params[:entry])
    if @entry.save
      flash[:success] = "Successfully created a new entry"
      redirect_to([@diary, @entry])
    else
      render 'entries/new'
    end
  end

private
  def diary_exist
    @diary = Diary.find_by_id(params[:diary_id])
    if @diary.nil?
      flash[:error] = "You tried to access a non-existing diary."
      redirect_to root_path
    end
  end

  def author_of_diary
    unless current_user.author?(@diary)
      flash[:error] = "You are not an author of '#{@diary.title}'"
      logger.debug("non author access: diary_path(@diary)=#{diary_path(@diary)}")
      redirect_to diary_path(@diary)
    end
  end
end
