
class Diary < ActiveRecord::Base
  attr_accessible :title, :desc
  has_many(:entries, :dependent => :destroy)
  has_many(:reverse_authorships,
           :foreign_key => "diary_id",
           :class_name => "Authorship")
  has_many(:authors, :through => :reverse_authorships)
  has_many(:opt_columns, :dependent => :destroy)
  has_many(:opt_records, :dependent => :destroy)

  validates(:title,
            :presence => true,
            :length => { :maximum => 255 })
end
# == Schema Information
#
# Table name: diaries
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  desc       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

