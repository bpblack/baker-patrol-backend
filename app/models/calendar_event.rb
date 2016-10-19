class CalendarEvent < ApplicationRecord
  attr_encrypted :uuid, key: ENV['CALENDAR_EVENT_UUID_KEY']
  belongs_to :patrol
  belongs_to :owner, polymorphic: true
end
