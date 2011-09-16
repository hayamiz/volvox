class OptColumn < ActiveRecord::Base
  attr_accessible :name, :col_type

  belongs_to :diary

  validates(:name, :presence => true)
  validates(:col_type,
            :inclusion => { :in => 1..2})

  # column types
  COL_INTEGER	= 1
  COL_FLOAT	= 2

  class << self
    def col_type_name(num)
      case num
      when COL_INTEGER
        "COL_INTEGER"
      when COL_FLOAT
        "COL_FLOAT"
      else
        nil
      end
    end
  end
end
# == Schema Information
#
# Table name: opt_columns
#
#  id         :integer         not null, primary key
#  diary_id   :integer
#  name       :string(255)
#  col_type   :integer
#  created_at :datetime
#  updated_at :datetime
#

