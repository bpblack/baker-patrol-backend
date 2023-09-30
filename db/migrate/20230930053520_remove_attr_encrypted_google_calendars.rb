class RemoveAttrEncryptedGoogleCalendars < ActiveRecord::Migration[7.0]
  def change
    remove_column :google_calendars, :encrypted_calendar_id
    remove_column :google_calendars, :encrypted_calendar_id_iv
    remove_column :google_calendars, :encrypted_refresh_token
    remove_column :google_calendars, :encrypted_refresh_token_iv
  end
end
