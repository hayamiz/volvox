class DeleteUserIdFromEntry < ActiveRecord::Migration
  def up
    remove_column :entries, :user_id
  end

  def down
    add_column :entries, :user_id, :integer
  end
end
