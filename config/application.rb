require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bakerapi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

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
      {role: :avy1, name: 'Avy 1 Instr', resourced: true},
      {role: :avy2, name: 'Avy 2 Instr', resourced: true},
      {role: :mtr, name: 'MTR Instr', resourced: true},
      {role: :oet, name: "OET Instr", resourced: true},
      {role: :oeci, name: "OEC Instr", resourced: true},  
      # specific oec and toboggan extra roles for hosts so they don't get patrol sub requests
      {role: :oec, name: 'OEC', resourced: true},
      {role: :tbgn, name: "Toboggan", resourced: true}
    ]
    config.num_weekends = 22
  end
end
