
class ColumnExistenceValidator < ActiveModel::Validator
  def validate(record)
    errors = record.errors

    unless record[:value].is_a? Hash
      errors[:value] << " must be an instace of Hash"
      return
    end

    diary = Diary.find_by_id(record[:diary_id])
    columns = diary.opt_columns.all
    record.value.each do |key, val|
      column = columns.find{|col| col.ckey == key}
      if column.nil?
        errors[:value] << " includes invalid column key: #{key}"
        next
      end

      col_type = column.col_type
      klass = case col_type
              when OptColumn::COL_INTEGER
                Integer
              when OptColumn::COL_FLOAT
                Float
              when OptColumn::COL_STRING
                String
              else
                errors[:col_type] << "#{col_type} is unknown"
              end
      unless val.is_a? klass
        errors[:value] << " have invalid type in column: #{key}. Expected: #{klass}, actual: #{val.class}"
      end
    end
  end
end

class OptRecord < ActiveRecord::Base
  attr_accessible :time, :value
  default_scope :order => 'opt_records.time DESC'

  validates(:time, :presence => true)
  validates(:value, :presence => true)
  validates_with(ColumnExistenceValidator)

  belongs_to :diary

  def method_missing(name, *args)
    if /\A(c(\d+))(=?)\Z/ =~ name.to_s
      col = self.diary.opt_columns.find_by_id($~[2].to_i)
      return super unless col
      key = $~[1].to_sym
      val = self.value
      if $~[3] == "="
        val[key] = args[0]
      else
        val[key]
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

  def value
    val = self[:value]
    if val.nil?
      {}
    elsif val.is_a? String
      YAML.load(val)
    else
      val
    end
  end

  class << self
    def of(opt_column)
      unless opt_column && opt_column.diary
        return []
      end

      opt_column.diary.opt_records.select do |rec|
        ! rec.value[opt_column.ckey].nil?
      end
    end
  end
end
# == Schema Information
#
# Table name: opt_records
#
#  id         :integer         not null, primary key
#  value      :string(255)
#  diary_id   :integer
#  created_at :datetime
#  updated_at :datetime
#  time       :datetime
#

