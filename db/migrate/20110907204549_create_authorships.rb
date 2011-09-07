class CreateAuthorships < ActiveRecord::Migration
  def change
    create_table :authorships do |t|
      t.integer :user_id
      t.integer :diary_id

      t.timestamps
    end
    add_index :authorships, :user_id
    add_index :authorships, :diary_id
    add_index :authorships, [:user_id, :diary_id], :unique => true
  end
end
