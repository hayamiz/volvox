class CreateOptColumns < ActiveRecord::Migration
  def change
    create_table :opt_columns do |t|
      t.integer :diary_id, :null_allowed => false
      t.string :name, :null_allowed => false
      t.integer :col_type, :null_allowed => false

      t.timestamps
    end
  end
end
