# frozen_string_literal: true

require './require_app'
require 'rack/attack'
require 'sidekiq'
require 'sidekiq/web'
require 'sidekiq-scheduler/web'
require_app

# Enable Rack::Attack
use Rack::Attack

# Rack::Session::Cookie provides simple cookie based session management.
# By default, the session is a Ruby Hash stored as base64 encoded marshalled data set to :key (default: rack.session).
Sidekiq::Web.use(Rack::Session::Cookie, secret: ENV['SECRET_KEY_BASE'])

# Secure Sidekiq::Web dashboard with HTTP Basic Authentication using Rack::Auth::Basic.
Sidekiq::Web.use(Rack::Auth::Basic) do |username, password|
  [username, password] == [ENV['SIDEKIQ_USER'], ENV['SIDEKIQ_PASSWORD']]
end

# Rack::URLMap takes a hash mapping urls or paths to apps, and dispatches accordingly.
run Rack::URLMap.new('/' => NotificationTesting::App.freeze.app, '/sidekiq' => Sidekiq::Web)
