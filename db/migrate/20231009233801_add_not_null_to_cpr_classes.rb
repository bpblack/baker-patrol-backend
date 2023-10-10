class AddNotNullToCprClasses < ActiveRecord::Migration[7.0]
  def change
    change_column_null :cpr_classes, :time, false
    change_column_null :cpr_classes, :class_size, false
    add_index :cpr_classes, [:time, :classroom_id], unique: true
  end
end