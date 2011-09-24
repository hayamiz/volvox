class RemoveTimeFromOptColumn < ActiveRecord::Migration
  def up
    remove_column :opt_records, :time
  end

  def down
    add_column :opt_records, :time, :time
  end
end
