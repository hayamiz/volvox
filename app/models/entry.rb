
class AttributesExistenceValidator < ActiveModel::Validator
  def validate(record)
    attrs = [:action_feed, :action_care, :pet_feces, :pet_physical, :memo]
    if attrs.all?{|attr| record[attr].nil? || record[attr].empty? }
      record.errors[:empty] << "One of #{attrs.join(", ")} must be non-empty"
    end
  end
end

class Entry < ActiveRecord::Base
  attr_accessible :date, :temperature, :humidity,
                  :action_feed, :action_care,
                  :pet_feces, :pet_physical, :memo
  belongs_to :diary
  default_scope :order => 'entries.date DESC'

  validates(:date, :presence => true,
            :uniqueness => {:scope => :diary_id})
  validates_with(AttributesExistenceValidator)
end
# == Schema Information
#
# Table name: entries
#
#  id           :integer         not null, primary key
#  created_at   :datetime
#  updated_at   :datetime
#  diary_id     :integer
#  date         :date
#  temperature  :float
#  humidity     :float
#  action_feed  :text
#  action_care  :text
#  pet_feces    :text
#  pet_physical :text
#  memo         :text
#

