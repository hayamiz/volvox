class OptColumnsController < ApplicationController
  include DiariesChildrenHelper

  before_filter(:authenticate, :only => [:create])
  before_filter(:diary_exist)
  before_filter(:author_of_diary, :only => [:create])
  
  def create
    @opt_column = @diary.opt_columns.new(params[:opt_column])
    if @opt_column.save
      flash[:success] = "The new column '#{@opt_column.name}' successfully created."
    else
      flash[:error] = "You failed to create a new column."
    end
    redirect_to edit_diary_path(@diary)
  end
end
