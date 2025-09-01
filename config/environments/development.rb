require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Make code changes take effect immediately without server restart.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing.
  config.server_timing = true

  # Enable/disable Action Controller caching. By default Action Controller caching is disabled.
  # Run rails dev:cache to toggle Action Controller caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.public_file_server.headers = { "cache-control" => "public, max-age=#{2.days.to_i}" }
  else
    config.action_controller.perform_caching = false
  end

  # Change to :null_store to avoid any caching.
  config.cache_store = :memory_store

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_deliveries = false

  # Make template changes take effect immediately.
  config.action_mailer.perform_caching = false

  # Set localhost to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

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
  
  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log
  config.logger = Logger.new('log/development.log')
  config.log_formatter = ::Logger::Formatter.new
  config.log_level = :debug

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Append comments with runtime information tags to SQL queries in logs.
  config.active_record.query_log_tags_enabled = true

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true
end
