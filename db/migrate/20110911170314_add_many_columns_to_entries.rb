class AddManyColumnsToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :date, :date
    add_column :entries, :temperature, :float
    add_column :entries, :humidity, :float
    add_column :entries, :action_feed, :text
    add_column :entries, :action_care, :text
    add_column :entries, :pet_feces, :text
    add_column :entries, :pet_physical, :text
    add_column :entries, :memo, :text
  end
end
