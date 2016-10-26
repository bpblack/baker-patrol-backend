class SubstitutionGoogleCalendarJob < ApplicationJob
  include BakerGoogle
  queue_as :default

  def perform(substitution_id)
    substitution = Substitution.find(substitution_id)
    if substitution.nil?
      return
    end
    patrol = substitution.patrol

    # remove the event from the previous owner's calendar
    user = substitution.user
    unless user.google_calendar.nil? || patrol.google_event.nil?
      google_service(refresh_token: user.google_calendar.refresh_token).delete_event(user.google_calendar.calendar_id, patrol.google_event.uuid) do |res, err|
        if err && google_batch_error(err)
          retry_job(wait: 30.minutes)
        else
          patrol.google_event.destroy
          patrol.reload
        end
      end
    end

    # add an event to the new owner's calendar
    user = substitution.sub
    unless user.google_calendar.nil?
      event = google_event(
        date: patrol.duty_day.date, 
        team: patrol.duty_day.team.name, 
        responsibility: patrol.patrol_responsibility.versioned_name
      )
      google_service(refresh_token: user.google_calendar.refresh_token).insert_event(user.google_calendar.calendar_id, event) do |res, err|
        if err
          retry_job(wait: 30.minutes) if google_batch_error(err)
        else
          CalendarEvent.create!(owner: user.google_calendar, patrol_id: patrol.id, uuid: res.id)
        end
      end
    end
  end
end

