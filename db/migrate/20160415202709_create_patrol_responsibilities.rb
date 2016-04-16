class CreatePatrolResponsibilities < ActiveRecord::Migration[5.0]
  def change
    create_table :patrol_responsibilities do |t|
      t.string :name
      t.integer :version
      t.string :runs
      t.string :ropelines
      t.string :other

      t.timestamps
    end

    add_index :patrol_responsibilities, [:name, :version], unique: true
  end
end
