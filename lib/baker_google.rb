module BakerGoogle
  require 'googleauth'
  require 'google/apis/calendar_v3'
  require 'google/api_client/client_secrets'

  def google_auth(**options)
    client = File.join(Rails.root, 'config', 'google_client_secret.json')
    client_secrets = Google::APIClient::ClientSecrets.load(client)
    auth_client = client_secrets.to_authorization
    auth_client.update!(options)
    return auth_client
  end
  
  # refresh token should not be nil if auth client is nil
  def google_service(refresh_token: nil, auth_client: nil)
    raise Google::Apis::ClientError if refresh_token.nil? && auth_client.nil?
    auth_client = google_auth(refresh_token: refresh_token, scope: Google::Apis::CalendarV3::AUTH_CALENDAR) if (auth_client.nil?)
    service = Google::Apis::CalendarV3::CalendarService.new
    service.client_options.application_name = Rails.application.config.google[:service_application_name]
    service.authorization = auth_client.fetch_access_token!["access_token"]
    return service
  end

  def google_event(date:, team:, responsibility:)
    zone_name = ActiveSupport::TimeZone::MAPPING[Time.zone.name]
    reminders = Google::Apis::CalendarV3::Event::Reminders.new({use_default:false, overrides: [{minutes: 1440, reminder_method: "email"}]})
    return Google::Apis::CalendarV3::Event.new({
      summary: 'Mt. Baker Duty Day',
      location: Rails.application.config.google[:event_location],
      description: "#{team} duty day with responsibility #{responsibility}",
      start: {
        date_time: Time.zone.parse("#{date}T08:00:00").strftime('%FT%T%:z'),
        time_zone: zone_name
      },
      end: {
        date_time: Time.zone.parse("#{date}T17:00:00").strftime('%FT%T%:z'),
        time_zone: zone_name
      },
      reminders: reminders
    })
  end

  def google_batch_error(e)
    b = begin
      throw e
    rescue Google::Apis::ServerError => e
      logger.error e.inspect
      true
    rescue Exception => e
      logger.error e.inspect
      false
    end
    return b
  end

  def google_revoke(refresh_token:)
    uri = URI(Rails.application.config.google[:revoke_uri])
    params = { :token => refresh_token }
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get(uri)
  end
end

