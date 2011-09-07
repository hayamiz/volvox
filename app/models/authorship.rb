
class Authorship < ActiveRecord::Base
  attr_accessible :diary_id

  belongs_to :author, :class_name => "User", :foreign_key => "user_id"
  belongs_to :diary, :class_name => "Diary"

  validates(:user_id, :presence => true)
  validates(:diary_id, :presence => true)
end
