require File.expand_path('../boot', __FILE__)

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bakerapi
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    config.active_job.queue_adapter = :sucker_punch
    config.time_zone = "Pacific Time (US & Canada)"
    config.autoload_paths << "#{Rails.root}/lib"

    # array of roles, resourced indicates whether it is tied to a roster spot
    config.duty_day_patrol_ranks = {
      role: { onhill: 1, aidroom: 2, host: 3},
      responsibility: {team_leader: 1, unspecified: 2, base: 3}
    }
    config.team_role_ranks = [
      {role: :leader, resourced: true, rank: 1},
      {role: :onhill, resourced: true, rank: 2},
      {role: :aidroom, resourced: true, rank: 2},
      {role: :host, resourced: true, rank: 3}
    ]
    config.team_roles = [
      {role: :leader, name: 'Leader', resourced: true}, 
      {role: :onhill, name: 'OEC', resourced: true}, 
      {role: :host, name: 'Host', resourced: true},
      {role: :aidroom, name: 'Aid Room', resourced: true}
    ] 
  end
end
