
class Diary < ActiveRecord::Base
  has_many :entries

  validates(:title,
            :presence => true,
            :length => { :maximum => 255 })
end
