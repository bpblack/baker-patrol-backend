class GoogleCalendarsController < ApplicationController
  include BakerGoogle
  before_action :authenticate_user
  rescue_from Google::Apis::Error, with: :google_exception
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  
  def authorize
    Pundit::authorize current_user, GoogleCalendar, 'authorize?' #only allowed to do this if current user doesn't have a google calendar
    ac = google_auth(
      refresh_token: nil, 
      redirect_uri: Rails.application.config.google[:redirect_uri], 
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR, 
      additional_parameters: {"access_type" => "offline", "approval_prompt" => "force"}
    )
    render json: {uri: ac.authorization_uri.to_s}, status: :ok
  end

  def create
    Pundit::authorize current_user, GoogleCalendar, 'create?' #only allowed to do this if the current user doesn't have a google calendar
    ac = google_auth(refresh_token: nil, redirect_uri: Rails.application.config.google[:redirect_uri], code: params[:code])
    ac.fetch_access_token!
    current_user.calendars.push(Calendar.create!(calendar: GoogleCalendar.create!(refresh_token: ac.refresh_token), user_id: current_user.id))
    current_user.reload
    render json: { google: calendar_list(ac) }, status: :ok
  end

  def calendars 
    if (current_user.google_calendar.nil?)
      json = { google: nil }
    else
      json = {google: calendar_list}
    end
    render json: json, status: :ok
  end

  def select
    Pundit::authorize current_user, GoogleCalendar, 'select?'
    old_calendar_id = current_user.google_calendar.calendar_id
    current_user.google_calendar.update!(calendar_id: params[:calendar_id])
    ChangeGoogleCalendarJob.perform_later(current_user, old_calendar_id)
    head :no_content
  end

  def destroy
    Pundit::authorize current_user, GoogleCalendar, 'destroy?'
    current_user.google_calendar.events.update_all({patrol_id: nil})
    RemoveGoogleCalendarJob.perform_later(current_user.google_calendar)
    current_user.google_calendar.calendar.update!(user_id: nil)
    head :no_content
  end

  private
  def calendar_list(auth = nil)
    s = google_service(refresh_token: (auth.nil?) ? current_user.google_calendar.refresh_token : nil, auth_client: auth)
    calendars = s.list_calendar_lists.items.reduce([]) do |arr, c| 
      arr << {name: c.summary, id: c.id} if c.access_role == "owner" 
      arr
    end
    { current: current_user.google_calendar.calendar_id, calendars: calendars }
  end

  def google_exception(exception)
    render json: "Google Error: #{exception.message}", status: :bad_reqeust
  end

  def user_not_authorized(exception)
    case exception.query
    when "authorize?", "create?"
      msg = "You already have a linked Google calendar."
    else
      msg = "You don't have a linked Google calendar."
    end
    render json: msg, status: :bad_request
  end
end
