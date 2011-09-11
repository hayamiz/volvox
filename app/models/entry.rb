
class Entry < ActiveRecord::Base
  attr_accessible :title, :content
  belongs_to :diary
  default_scope :order => 'entries.created_at DESC'

end
# == Schema Information
#
# Table name: entries
#
#  id         :integer         not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  diary_id   :integer
#

