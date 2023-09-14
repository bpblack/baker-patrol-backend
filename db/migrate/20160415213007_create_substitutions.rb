class CreateSubstitutions < ActiveRecord::Migration[5.0]
  def change
    create_table :substitutions do |t|
      t.integer :user_id
      t.integer :patrol_id
      t.string :reason

      t.timestamps
    end

    add_index :substitutions, :user_id
    add_index :substitutions, :patrol_id
    add_foreign_key :substitutions, :users
    add_foreign_key :substitutions, :patrols
  end
end
