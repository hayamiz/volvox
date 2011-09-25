class OptColumnsController < ApplicationController
  include DiariesChildrenHelper

  before_filter(:authenticate, :only => [:create])
  before_filter(:diary_exist)
  before_filter(:author_of_diary, :only => [:create])
  before_filter(:opt_column_exist, :only => [:show])
  
  def create
    @opt_column = @diary.opt_columns.new(params[:opt_column])
    if @opt_column.save
      flash[:success] = "The new column '#{@opt_column.name}' successfully created."
    else
      flash[:error] = "You failed to create a new column."
    end
    redirect_to edit_diary_path(@diary)
  end

  def show
    @opt_records = OptRecord.of(@opt_column).sort_by(&:time)
  end

  private
  def opt_column_exist
    @opt_column = OptColumn.find_by_id(params[:id])
    unless @opt_column
      not_found
    end
  end
end
