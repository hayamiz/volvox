
class Entry < ActiveRecord::Base
  attr_accessible :title, :content
  belongs_to :diary
  default_scope :order => 'entries.created_at DESC'

  validates(:title,
            :presence => true,
            :length => { :maximum => 255})
  validates(:content,
            :presence => true)
end
# == Schema Information
#
# Table name: entries
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  content    :text
#  created_at :datetime
#  updated_at :datetime
#  diary_id   :integer
#

