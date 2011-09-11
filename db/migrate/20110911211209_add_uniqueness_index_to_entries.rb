class AddUniquenessIndexToEntries < ActiveRecord::Migration
  def up
    add_index :entries, :date, :name => "idx_date_unique", :unique => true
  end

  def down
    remove_index :entries, :name => "idx_date_unique"
  end
end
