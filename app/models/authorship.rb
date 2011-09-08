
class Authorship < ActiveRecord::Base
  attr_accessible :diary_id

  belongs_to :author, :class_name => "User", :foreign_key => "user_id"
  belongs_to :diary, :class_name => "Diary", :foreign_key => "diary_id"

  validates(:user_id, :presence => true)
  validates(:diary_id, :presence => true)
  validate :diary_existence

  private
  def diary_existence
    unless Diary.find_by_id(self.diary_id)
      errors.add(:diary, "must be exist")
    end
  end
end
# == Schema Information
#
# Table name: authorships
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  diary_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

