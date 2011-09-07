class CreateDiaries < ActiveRecord::Migration
  def change
    create_table :diaries do |t|
      t.string :title
      t.string :desc

      t.timestamps
    end
  end
end
