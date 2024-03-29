
class DiariesController < ApplicationController
  include ApplicationHelper

  before_filter(:authenticate,
                :only => [:new, :create, :edit, :update])
  before_filter(:author,
                :only => [:edit, :update])

  def new
    @title = t('diaries.new.title')
    @diary = Diary.new
  end

  def create
    @diary = Diary.new(params[:diary])
    if @diary.valid?
      ActiveRecord::Base::transaction do
        @diary.save!
        current_user.participate(@diary)
      end
      flash[:success] = "The diary '#{@diary.title}' created successfully!"
      redirect_to root_path
    else
      render "diaries/new"
    end
  end

  def edit
    @title = t('diaries.edit.title')
    @opt_column = @diary.opt_columns.build
    @opt_columns = @diary.opt_columns.all
    add_debug(@opt_columns)
  end

  def update
    if @diary.update_attributes(params[:diary])
      flash[:success] = "Updated the diary settings successfully"
      redirect_to @diary
    else
      edit
      render "diaries/edit"
    end
  end

  def show
    @diary = Diary.find_by_id(params[:id])
    if @diary
      @title = @diary.title
      @entries = @diary.entries.paginate(:page => params[:page])
      @opt_columns = @diary.opt_columns.all

      if @opt_columns.size > 0
        @record_counts = Hash.new { 0 }
        @diary.opt_records.each do |rec|
          @opt_columns.each do |col|
            @record_counts[col.ckey] += 1 if rec.value[col.ckey]
          end
        end
      end
    else
      not_found
    end
  end

  private
  def author
    @diary = Diary.find_by_id(params[:id])
    redirect_back_or signin_path unless current_user.author?(@diary)
  end
end
