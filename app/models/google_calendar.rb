class GoogleCalendar < ApplicationRecord
  encrypts :calendar_id
  encrypts :refresh_token
  has_one :calendar, as: :calendar, dependent: :destroy
  has_many :events, as: :owner, class_name: 'CalendarEvent', dependent: :destroy
end
