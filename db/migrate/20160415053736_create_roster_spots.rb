class CreateRosterSpots < ActiveRecord::Migration[5.0]
  def change
    create_table :roster_spots do |t|
      t.integer :season_id
      t.integer :team_id
      t.integer :user_id

      t.timestamps
    end

    add_index :roster_spots, :season_id
    add_index :roster_spots, :team_id
    add_index :roster_spots, :user_id
    add_index :roster_spots, [:season_id, :user_id], unique: true
    add_foreign_key :roster_spots, :seasons
    add_foreign_key :roster_spots, :teams
    add_foreign_key :roster_spots, :users
  end
end
