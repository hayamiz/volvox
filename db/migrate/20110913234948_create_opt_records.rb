class CreateOptRecords < ActiveRecord::Migration
  def change
    create_table :opt_records do |t|
      t.time :time
      t.string :value
      t.integer :diary_id

      t.timestamps
    end
  end
end
