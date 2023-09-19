class GoogleCalendar < ApplicationRecord
  attr_encrypted :calendar_id, key: Rails.application.credentials.google.calendar_id
  attr_encrypted :refresh_token, key: Rails.application.credentials.google.refresh_token
  has_one :calendar, as: :calendar, dependent: :destroy
  has_many :events, as: :owner, class_name: 'CalendarEvent', dependent: :destroy
end
