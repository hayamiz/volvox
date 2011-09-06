class AddPasswordToUsers < ActiveRecord::Migration
  def change
    add_column :users, :encrypted_password, :string
    add_column :users, :salt, :string
  end
end
