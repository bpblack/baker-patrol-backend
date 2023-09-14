class CreateCalendarEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :calendar_events do |t|
      t.references :owner, polymorphic: true, null: false
      t.references :patrol, foreign_key: true
      t.string :encrypted_uuid
      t.string :encrypted_uuid_iv

      t.timestamps
    end
    add_index :calendar_events, [:patrol_id, :owner_id, :owner_type], unique: true, name: 'patrol_unique_to_calendar'
  end
end
