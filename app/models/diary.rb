
class Diary < ActiveRecord::Base
  attr_accessible :title, :desc
  has_many(:entries, :dependent => :destroy)
  has_many(:reverse_authorships,
           :foreign_key => "diary_id",
           :class_name => "Authorship")
  has_many(:authors, :through => :reverse_authorships)

  validates(:title,
            :presence => true,
            :length => { :maximum => 255 })
end
