class CreatePatrols < ActiveRecord::Migration[5.0]
  def change
    create_table :patrols do |t|
      t.integer :user_id
      t.integer :duty_day_id
      t.integer :patrol_responsibility_id

      t.timestamps

    end
    add_index :patrols, :user_id
    add_index :patrols, :duty_day_id
    add_index :patrols, :patrol_responsibility_id
    add_index :patrols, [:user_id, :duty_day_id], unique: true
    add_index :patrols, [:patrol_responsibility_id, :duty_day_id], unique: true
    add_foreign_key :patrols, :users
    add_foreign_key :patrols, :duty_days
    add_foreign_key :patrols, :patrol_responsibilities
  end
end
