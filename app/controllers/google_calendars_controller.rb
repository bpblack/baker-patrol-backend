class GoogleCalendarsController < ApplicationController
  require 'googleauth'
  require 'google/apis/calendar_v3'
  require 'google/api_client/client_secrets'
  before_action :authenticate_user
  
  def authorize
    Pundit::authorize current_user, GoogleCalendar, 'authorize?' #only allowed to do this if current user doesn't have a google calendar
    ac = auth_client
    ac.update!({
      redirect_uri: 'http://localhost:5555/Dash/Google',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      additional_parameters: {"access_type" => "offline", "approval_prompt" => "force"}
    })
    render json: {uri: ac.authorization_uri.to_s}, status: :ok
  end

  def create
    Pundit::authorize current_user, GoogleCalendar, 'create?' #only allowed to do this if the current user doesn't have a google calendar
    ac = auth_client
    ac.update!({
      redirect_uri: 'http://localhost:5555/Dash/Google'
    })
    ac.code = params[:code]
    ac.fetch_access_token!
    current_user.calendars.push(Calendar.create!(calendar: GoogleCalendar.create!(refresh_token: ac.refresh_token)))
    current_user.reload
    render json: calendar_list(ac), status: :ok
  end

  def calendars
    Pundit::authorize current_user, GoogleCalendar, 'calendars?'
    render json: calendar_list, status: :ok
  end

  def select
    Pundit::authorize current_user, GoogleCalendar, 'select?'
    old_calendar_id = current_user.google_calendar.calendar_id
    current_user.google_calendar.update!(calendar_id: params[:calendar_id])
    if (old_calendar_id.nil?)
      #create cal job
    else
      #change cal job
    end
    head :no_content
  end

  def destroy
    Pundit::authorize current_user, GoogleCalendar, 'destroy?'
    uri = URI('https://accounts.google.com/o/oauth2/revoke')
    params = { :token => current_user.google_calendar.refresh_token }
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get(uri)
    current_user.google_calendar.destroy!
    head :no_content
  end

  private

  def auth_client
    client = File.join(Rails.root, 'config', 'google_client_secret.json')
    client_secrets = Google::APIClient::ClientSecrets.load(client)
    auth_client = client_secrets.to_authorization
    return auth_client
  end

  def api_service(ac)
    service = Google::Apis::CalendarV3::CalendarService.new
    service.client_options.application_name = 'Mt Baker Volunteer API'
    if (ac.nil?) 
      ac = auth_client
      ac.refresh_token = current_user.google_calendar.refresh_token
    end
    service.authorization = ac.fetch_access_token!['access_token']
    return service
  end

  def calendar_list(token=nil)
    s = api_service(token)
    { current: current_user.google_calendar.calendar_id, calendars: s.list_calendar_lists.items.map { |c| {name: c.summary, id: c.id} } }
  end
end
