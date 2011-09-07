
class Diary < ActiveRecord::Base
  attr_accessible :title, :desc
  has_many :entries

  validates(:title,
            :presence => true,
            :length => { :maximum => 255 })
end
