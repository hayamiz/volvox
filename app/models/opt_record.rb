class OptRecord < ActiveRecord::Base
  attr_accessible :time, :value

  validates(:time, :presence => true)
  validates(:value, :presence => true)

  belongs_to :diary

  def method_missing(name, *args)
    if /\A(c(\d+))(=?)\Z/ =~ name.to_s
      col = OptColumn.find_by_id($~[2].to_i)
      super unless col
      key = $~[1].to_sym
      if $~[3] == "="
        col
      else
        col
      end
    else
      super
    end
  end

  def respond_to?(method)
    if method =~ /\Ac(\d+)=?\Z/
      if OptColumn.find_by_id($~[1].to_i)
        return true
      end
    end
    super
  end
end
# == Schema Information
#
# Table name: opt_records
#
#  id         :integer         not null, primary key
#  time       :time
#  value      :string(255)
#  diary_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

