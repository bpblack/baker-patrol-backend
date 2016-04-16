class CreateSeasons < ActiveRecord::Migration[5.0]
  def change
    create_table :seasons do |t|
      t.string :name
      t.date :start
      t.date :end

      t.timestamps
    end

    add_index :seasons, :name, unique: true
  end
end
