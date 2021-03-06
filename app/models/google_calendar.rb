class GoogleCalendar < ApplicationRecord
  attr_encrypted :calendar_id, key: ENV['GOOGLE_CAL_CALENDAR_ID_KEY']
  attr_encrypted :refresh_token, key: ENV['GOOGLE_CAL_REFRESH_TOKEN_KEY']
  has_one :calendar, as: :calendar, dependent: :destroy
  has_many :events, as: :owner, class_name: 'CalendarEvent', dependent: :destroy
end
