class CreateTeams < ActiveRecord::Migration[5.0]
  def change
    create_table :teams do |t|
      t.string :name

      t.timestamps
    end

    add_index :teams, :name, unique: true
  end
end
