class GoogleCalendar < ApplicationRecord
  attr_encrypted :calendar_id, key: ENV['GOOGLE_CAL_CALENDAR_ID_KEY'], unless: Rails.env.development?
  attr_encrypted :refresh_token, key: ENV['GOOGLE_CAL_REFRESH_TOKEN_KEY'], unless: Rails.env.development?
  has_one :calendar, as: :calendar, dependent: :destroy
end
