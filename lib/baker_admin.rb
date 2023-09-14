# to use in the rails console on heroku
#   1) require "./lib/baker_admin.rb"
#   2) include BakerAdmin
module BakerAdmin
  include BakerGoogle

  def seed_events
    GoogleCalendar.all.each do |google_calendar|
      begin
        puts google_calendar.calendar.user.name
        future_patrol_ids = google_calendar.calendar.user.patrols.includes(:duty_day).where("duty_days.date >= :today", {today: Date.today}).pluck(:id)
        future_patrols = Patrol.includes({duty_day: :team}, :patrol_responsibility, :google_event).where(id: future_patrol_ids)
        puts future_patrols
        service = google_service(refresh_token: google_calendar.refresh_token)
        service.batch do |s|
          future_patrols.each do |patrol|
            if patrol.google_event.nil?
              event = google_event(date: patrol.duty_day.date, team: patrol.duty_day.team.name, responsibility: patrol.patrol_responsibility.versioned_name)
              s.insert_event(google_calendar.calendar_id, event) do |res, err|
                raise err unless err.nil?
                CalendarEvent.create!(owner_id: google_calendar.id, owner_type: google_calendar.class.name, patrol_id: patrol.id, uuid: res.id)
              end
            end
          end
        end
      rescue Exception => e
        puts e.inspect
      end
    end
  end

  def seed_calendar_events(calendar_id)
    google_calendar = GoogleCalendar.find(calendar_id)
    puts google_calendar.calendar.user.name
    future_patrol_ids = google_calendar.calendar.user.patrols.includes(:duty_day).where("duty_days.date >= :today", {today: Date.today}).pluck(:id)
    future_patrols = Patrol.includes({duty_day: :team}, :patrol_responsibility, :google_event).where(id: future_patrol_ids)
    puts future_patrols
    service = google_service(refresh_token: google_calendar.refresh_token)
    service.batch do |s|
      future_patrols.each do |patrol|
        if patrol.google_event.nil?
          event = google_event(date: patrol.duty_day.date, team: patrol.duty_day.team.name, responsibility: patrol.patrol_responsibility.versioned_name)
          s.insert_event(google_calendar.calendar_id, event) do |res, err|
            raise err unless err.nil?
            CalendarEvent.create!(owner_id: google_calendar.id, owner_type: google_calendar.class.name, patrol_id: patrol.id, uuid: res.id)
          end
        end
      end
    end
  end
end
