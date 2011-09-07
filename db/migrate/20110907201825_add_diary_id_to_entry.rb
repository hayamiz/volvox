class AddDiaryIdToEntry < ActiveRecord::Migration
  def change
    add_column :entries, :diary_id, :integer
  end
end
