class AddCalendarIdRefreshTokenToGoogleCalendars < ActiveRecord::Migration[7.0]
  def change
    add_column :google_calendars, :calendar_id, :string
    add_column :google_calendars, :refresh_token, :string
  end
end
