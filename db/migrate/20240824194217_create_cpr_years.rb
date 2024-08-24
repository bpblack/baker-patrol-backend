class CreateCprYears < ActiveRecord::Migration[7.2]
  def change
    create_table :cpr_years do |t|
      t.date :year, null: false, index: {unique: true}

      t.timestamps
    end
  end
end
