class CreateGoogleCalendars < ActiveRecord::Migration[5.0]
  def change
    create_table :google_calendars do |t|
      t.string :encrypted_calendar_id
      t.string :encrypted_calendar_id_iv
      t.string :encrypted_refresh_token
      t.string :encrypted_refresh_token_iv

      t.timestamps
    end
  end
end
