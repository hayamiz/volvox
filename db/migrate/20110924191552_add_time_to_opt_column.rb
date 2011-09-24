class AddTimeToOptColumn < ActiveRecord::Migration
  def change
    add_column :opt_records, :time, :datetime
  end
end
