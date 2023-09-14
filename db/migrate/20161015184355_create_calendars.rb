class CreateCalendars < ActiveRecord::Migration[5.0]
  def change
    create_table :calendars do |t|
      t.references :user, foreign_key: true
      t.references :calendar, polymorphic: true

      t.timestamps
    end
    add_index :calendars, [:user_id, :calendar_type], unique: true
  end
end
