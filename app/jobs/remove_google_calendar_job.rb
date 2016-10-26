class RemoveGoogleCalendarJob < ApplicationJob
  include BakerGoogle
  queue_as :default

  def perform(google_calendar_id)
    google_calendar = GoogleCalendar.find(google_calendar_id)
    if google_calendar.nil?
      return
    end
    service = google_service(refresh_token: google_calendar.refresh_token)
    should_retry = false
    remove_ids = []
    if google_calendar.events.length > 0
      service.batch do |s|
        google_calendar.events.each do |event|
          unless (event.nil?) 
            s.delete_event(google_calendar.calendar_id, event.uuid) do |res, err|
              if (err)
                sr = google_batch_error(err)
                should_retry |= sr
                remove_ids << event.id unless sr
              else
                remove_ids << event.id
              end
            end
          end 
        end
      end
    end
    if (!should_retry)
      google_revoke(refresh_token: google_calendar.refresh_token)
      google_calendar.destroy
    else
      CalendarEvent.where(id: remove_ids).destroy_all
      retry_job(wait: 30.minutes)
    end
  end
end
