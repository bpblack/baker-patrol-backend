class CalendarEvent < ApplicationRecord
  attr_encrypted :uuid, key: Base64.decode64(ENV['CALENDAR_EVENT_UUID_KEY'])
  belongs_to :patrol
  belongs_to :owner, polymorphic: true
end
