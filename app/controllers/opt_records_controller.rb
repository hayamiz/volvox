class OptRecordsController < ApplicationController
  include DiariesChildrenHelper

  before_filter(:authenticate, :only => [:create])
  before_filter(:diary_exist)
  before_filter(:author_of_diary, :only => [:create])

  def index
    @opt_columns = @diary.opt_columns.all
    @opt_records = @diary.opt_records.all
  end

  def create
    @opt_record = @diary.opt_records.build(:time => params[:opt_record][:time])
    value = {}
    @diary.opt_columns.all.each do |col|
      ckey = col.ckey
      val = params[:opt_record][ckey]
      if val && (! val.empty?)
        case col.col_type
        when OptColumn::COL_INTEGER
          value[ckey] = val.to_i
        when OptColumn::COL_FLOAT
          value[ckey] = val.to_f
        when OptColumn::COL_STRING
          value[ckey] = val.to_s
        end
      end
    end
    @opt_record[:value] = value

    if @opt_record.save
      flash[:success] = "Added a record successfully"
    else
      flash[:error] = "Failed to create a record"
    end
    redirect_to diary_path(@diary)
  end
end
