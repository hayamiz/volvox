
class OptColumn < ActiveRecord::Base
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

    def add_col_type(name, val)
      @col_types = [] unless @col_types
      if @col_types.find{|n,_| n == name}
        return
      end
      self.const_set(name, val)
      @col_types.push([name, val])
    end

    def col_types()
      @col_types
    end
  end


  attr_accessible :name, :col_type

  belongs_to :diary

  validates(:name, :presence => true)
  validates(:col_type,
            :inclusion => { :in => 1..2})

  # column types
  add_col_type :COL_INTEGER,	1
  add_col_type :COL_FLOAT, 	2
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

