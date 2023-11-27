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
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    config.active_job.queue_adapter = :sucker_punch
    config.time_zone = "Pacific Time (US & Canada)"
    config.autoload_paths << "#{Rails.root}/lib/modules"

    # array of roles, resourced indicates whether it is tied to a roster spot
    config.duty_day_patrol_ranks = {
      role: { onhill: 1, tbgntrainer: 2, avytrainer: 3, host: 4, candidate: 5},
      responsibility: {team_leader: 1, rover: 2, unspecified: 3, base: 4, candidate: 5}
    }
    config.team_role_ranks = [
      {role: :director, resourced: true, rank: 0},
      {role: :leader, resourced: true, rank: 1},
      {role: :onhill, resourced: true, rank: 2},
      {role: :host, resourced: true, rank: 3},
      {role: :candidate, resourced: true, rank: 4}
    ]
    config.team_roles = [
      {role: :director, name: 'Director', resourced: true},
      {role: :leader, name: 'Leader', resourced: true}, 
      {role: :onhill, name: 'Patroller', resourced: true}, 
      {role: :host, name: 'Host', resourced: true},
      {role: :candidate, name: 'Candidate', resourced: true}
    ] 
    config.team_extra_roles = [
      {role: :senior, name: 'Senior', resourced: false},
      {role: :rigger, name: 'Rigger', resourced: true},
      {role: :avy1, name: 'Avy 1', resourced: false},
      {role: :avy2, name: 'Avy 2', resourced: false},
      {role: :mtr, name: 'MTR', resourced: false},
      # specific oec and toboggan extra roles for hosts so they don't get patrol sub requests
      {role: :oec, name: 'OEC', resourced: true},
      {role: :tbgn, name: "Toboggan", resourced: true}
    ]
    config.num_weekends = 24
  end
end
