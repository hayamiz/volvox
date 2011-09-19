module DiariesHelper
  private
  def author
    @diary = Diary.find_by_id(params[:id])
    redirect_back_or signin_path unless current_user.author?(@diary)
  end
end
