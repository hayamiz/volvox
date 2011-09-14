class OptRecord < ActiveRecord::Base
  attr_accessible :time, :value

  validates(:time, :presence => true)
  validates(:value, :presence => true)

  belongs_to :diary
end
