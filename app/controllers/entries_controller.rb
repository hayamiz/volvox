class EntriesController < ApplicationController
  before_filter :authenticate, :only => [:new, :edit, :create, :update]
  before_filter :diary_exist
  before_filter :author_of_diary, :only => [:new, :edit, :create, :update]
  before_filter :entry_exist, :only => [:edit, :update, :show]

  def new
    @entry = Entry.new
    @title = "New entry"
  end

  def create
    begin
      @entry = @diary.entries.build(params[:entry])
    rescue NoMethodError
      attr = params[:entry].dup
      attr.delete("date(1i)")
      attr.delete("date(2i)")
      attr.delete("date(3i)")
      @entry = @diary.entries.build(attr)
      render 'entries/new'
      return
    end

    if @entry.save
      flash[:success] = "Successfully created a new entry"
      redirect_to([@diary, @entry])
    else
      render 'entries/new'
    end
  end

  def edit
    @title = "Edit an entry"
  end

  def show
    @title = "#{@diary.title} | #{@entry.title}"
  end

private
  def diary_exist
    @diary = Diary.find_by_id(params[:diary_id])
    if @diary.nil?
      flash[:error] = "You tried to access a non-existing diary."
      redirect_to root_path
    end
  end

  def entry_exist
    @entry = Entry.find_by_id(params[:id])
    if @entry.nil?
      not_found
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
