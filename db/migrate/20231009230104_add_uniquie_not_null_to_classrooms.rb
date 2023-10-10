class AddUniquieNotNullToClassrooms < ActiveRecord::Migration[7.0]
  def change
    change_column_null :classrooms, :name, false
    change_column_null :classrooms, :address, false
    change_column_null :classrooms, :map_link, false
    add_index :classrooms, :address, unique: true
  end
end
