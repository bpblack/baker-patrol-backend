class ChangeGoogleCalendarJob < ApplicationJob
  include BakerGoogle
  queue_as :default

  def perform(user_id, old_calendar_id)
    # get all the info for the calendar events into an array of hashes, 1 DB hit
    user = User.find(user_id);
    if user.nil?
      return;
    end
    gc = user.google_calendar
    future_patrol_ids = user.patrols.includes(:duty_day).where("duty_days.date >= :today", {today: Date.today}).pluck(:id)

    unless gc.nil? || future_patrol_ids.length == 0
      # split into either an array of things to create or an array of things to move
      patrol_summaries = Patrol.includes({duty_day: :team}, :patrol_responsibility, :google_event).where(id: future_patrol_ids).inject({create: [], move: []}) do |h, p|
        key = p.google_event.nil? ? :create : :move
        h[key] << {id: p.id, date: p.duty_day.date, team: p.duty_day.team.name, responsibility: p.patrol_responsibility.versioned_name, uuid: (p.google_event.nil?) ? nil : p.google_event.uuid}
        h
      end

      # setup
      should_retry = false
      calendar_id = gc.calendar_id
      service = google_service(refresh_token: gc.refresh_token)

      # batch move already existing events
      if old_calendar_id && patrol_summaries[:move].length > 0
        service.batch do |s|
          patrol_summaries[:move].each do |ps|
            s.move_event(old_calendar_id, ps[:uuid], calendar_id) do |res, err| 
              if err
                should_retry |= google_batch_error(err)
              end
            end
          end
        end
      end

      # batch create new events
      if patrol_summaries[:create].length > 0
        new_events = []
        service.batch do |s|
          patrol_summaries[:create].each do |ps|
            #only create an event if it doesn't have a calendar entry
            event = google_event(date: ps[:date], team: ps[:team], responsibility: ps[:responsibility])
            s.insert_event(calendar_id, event) do |res, err|
              if err
                should_retry |= google_batch_error(err)
              else
                new_events << {owner_id: gc.id, owner_type: gc.class.name, patrol_id: ps[:id], uuid: res.id}
              end
            end
          end
        end
        CalendarEvent.create!(new_events) if new_events.length > 0
      end

      retry_job(wait: 30.minutes) if should_retry
    end
  end
end
