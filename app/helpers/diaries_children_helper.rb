module DiariesChildrenHelper
  private
  def diary_exist
    @diary = Diary.find_by_id(params[:diary_id])
    if @diary.nil?
      flash[:error] = t'entries.diary_exist.flash.non_exist'
      redirect_to root_path
    end
  end

  def author_of_diary
    unless current_user.author?(@diary)
      flash[:error] = t"entries.author_of_diary.flash.non_author", :title => @diary.title
      redirect_to diary_path(@diary)
    end
  end
end
