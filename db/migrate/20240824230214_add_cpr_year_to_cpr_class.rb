class AddCprYearToCprClass < ActiveRecord::Migration[7.2]
  def change
    add_reference :cpr_classes, :cpr_year, null: false, foreign_key: true
  end
end
