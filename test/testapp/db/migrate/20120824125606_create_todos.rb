class CreateTodos < ActiveRecord::Migration
  def change
    create_table :todos do |t|
      t.text :text
      t.boolean :done, null: false, default: false
      t.timestamps
    end
  end
end
