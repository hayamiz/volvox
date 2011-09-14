class AddIndexToOptRecordTime < ActiveRecord::Migration
  def change
    add_index :opt_records, :time, :name => "opt_records_time_idx"
  end
end
