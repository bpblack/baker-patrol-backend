class CalendarEvent < ApplicationRecord
  encrypts :uuid
  belongs_to :patrol
  belongs_to :owner, polymorphic: true
end
