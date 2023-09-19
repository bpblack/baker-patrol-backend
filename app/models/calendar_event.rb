class CalendarEvent < ApplicationRecord
  attr_encrypted :uuid, key: Rails.application.credentials.calendar_event
  belongs_to :patrol
  belongs_to :owner, polymorphic: true
end
