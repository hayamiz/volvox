class EntriesController < ApplicationController
  before_filter :authenticate, :only => [:new, :edit, :create, :update]
  before_filter :diary_exist
  before_filter :author_of_diary, :only => [:new, :edit, :create, :update]
  before_filter :entry_exist, :only => [:edit, :update, :show]

  def index
    redirect_to diary_path(params[:diary_id])
  end

  def new
    @entry = Entry.new
    @title = t"entries.new.title"
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
      flash[:success] = t"entries.create.flash.success"
      redirect_to([@diary, @entry])
    else
      render 'entries/new'
    end
  end

  def edit
    @title = t'entries.edit.title'
    @opt_record = @diary.opt_records.build
  end

  def update
    begin
      if @entry.update_attributes(params[:entry])
        redirect_to([@diary, @entry])
        return
      end
    rescue NoMethodError => err
      logger.error(err)
    end
    @opt_record = @diary.opt_records.build
    render 'entries/edit'
  end

  def show
    @title = "#{@diary.title} | #{@entry.date.to_s}"
  end

private
  def diary_exist
    @diary = Diary.find_by_id(params[:diary_id])
    if @diary.nil?
      flash[:error] = t'entries.diary_exist.flash.non_exist'
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
      flash[:error] = t"entries.author_of_diary.flash.non_author", :title => @diary.title
      redirect_to diary_path(@diary)
    end
  end
end
