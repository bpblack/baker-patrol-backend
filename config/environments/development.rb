Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  config.debug_exception_response_format = :api

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.action_mailer.perform_caching = false

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false

    config.action_mailer.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_deliveries = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  #logging 
  config.logger = Logger.new('log/development.log')
  config.log_formatter = ::Logger::Formatter.new
  config.log_level = :debug

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = false

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::FileUpdateChecker

  #config.force_ssl = true
  #config.ssl_options = { hsts: { preload: true }}
  
  #URL for use in mailers
  config.email_url = 'http://localhost:8000'

  # config.active_job.queue_adapter = :sucker_punch
  # config.action_mailer.raise_delivery_errors = true
  # config.action_mailer.default_url_options = { host: 'mtbakervoly.herokuapp.com' }
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = {
  #   address:              'smtp.gmail.com',
  #   port:                 587,
  #   domain:               'mtbakervoly.herokuapp.com',
  #   user_name:            Rails.application.credentials.gmail.user,
  #   password:             Rails.application.credentials.gmail.password,
  #   authentication:       :plain,
  #   enable_starttls_auto: true  
  # }

  # google calendar configuration
  config.google = {
    redirect_uri: 'http://localhost:4200/Google',
    revoke_uri: 'https://accounts.google.com/o/oauth2/revoke',
    service_application_name: 'Mt Baker Volunteer API',
    event_location: 'Mt. Baker Ski Area, Mount Baker Highway, Deming, WA',
    secrets: File.open(File.join(Rails.root, 'config', 'google_client_secret.json'), 'r') { |file| JSON.load(file.read) }
  }

  config.cpr_ior = {
    email: 'test@test.com',
    name: 'Someone Incharge'
  }
  config.cpr_url = 'http://localhost:4200/CprSignup/'
end
