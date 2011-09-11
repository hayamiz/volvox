class AddUniquenessIndexToEntries < ActiveRecord::Migration
  def up
    add_index :entries, [:date, :diary_id], :name => "idx_diary_id_date_unique", :unique => true
  end

  def down
    remove_index :entries, :name => "idx_diary_id_date_unique"
  end
end
