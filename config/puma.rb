# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum, this matches the default thread size of Active Record.
#
workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

# Specifies the `port` that Puma will listen on to receive requests, default is 3000.
#
port(ENV['PORT'] || 3000, "::")

# Router keepalive idle timeout + 5 seconds
persistent_timeout(95)

# Turn off keepalive support for better long tails response time with Router 2.0
# Remove this line when https://github.com/puma/puma/issues/3487 is closed, and the fix is released
enable_keep_alives(false) if respond_to?(:enable_keep_alives)

rackup      DefaultRackup if defined?(DefaultRackup)
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Worker-specific setup for Rails 4.1 to 5.2, after 5.2 it's not needed
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

if Rails.env.development?
  key_path=File.expand_path('.ssl/mkcert/localhost-key.pem')
  cert_path=File.expand_path('.ssl/mkcert/localhost.pem')
  
  ssl_bind 'localhost', '3000', {
    key: key_path,
    cert: cert_path,
    verify_mode: 'none'
  }
end
