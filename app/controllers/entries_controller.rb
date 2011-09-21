class EntriesController < ApplicationController
  include DiariesChildrenHelper

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
    if @entry.update_attributes(params[:entry])
      flash[:success] = t'entries.update.flash.success'
      redirect_to([@diary, @entry])
      return
    end
    @opt_record = @diary.opt_records.build
    render 'entries/edit'
  end

  def show
    @title = "#{@diary.title} | #{@entry.date.to_s}"
  end

private
  def entry_exist
    @entry = Entry.find_by_id(params[:id])
    if @entry.nil?
      not_found
    end
  end
end
