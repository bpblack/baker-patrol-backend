class CreateDutyDays < ActiveRecord::Migration[5.0]
  def change
    create_table :duty_days do |t|
      t.integer :season_id
      t.integer :team_id
      t.date :date

      t.timestamps
    end

    add_index :duty_days, :season_id
    add_index :duty_days, :team_id
    add_index :duty_days, [:team_id, :date], unique: true
    add_foreign_key :duty_days, :seasons
    add_foreign_key :duty_days, :teams
  end
end
