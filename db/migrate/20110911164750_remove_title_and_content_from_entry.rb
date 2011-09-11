class RemoveTitleAndContentFromEntry < ActiveRecord::Migration
  def up
    remove_column :entries, :title
    remove_column :entries, :content
  end

  def down
    add_column :entries, :title, :string
    add_column :entries, :content, :text
  end
end
