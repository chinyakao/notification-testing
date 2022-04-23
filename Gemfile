# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# Configuration and Utilities
gem 'figaro', '~> 1.2'
gem 'rack-attack'
gem 'rake'

# Web Application
gem 'puma', '~> 5.5'
gem 'roda', '~> 3.49'
gem 'slim', '~> 4.1'

# Validation
gem 'dry-struct', '~> 1.4'
gem 'dry-types', '~> 1.5'

# Database
gem 'sequel', '~> 5.49'

group :development, :test do
  gem 'sequel-seed'
  gem 'sqlite3', '~> 1.4'
end

group :production do
  gem 'pg'
end

# Networking
gem 'http', '~> 5.0'

# Notification
gem 'aws-sdk-sns'
gem 'nokogiri'
gem 'sidekiq'
gem 'sidekiq-scheduler'

group :development do
  gem 'rerun', '~> 0'
end

# Debugging
gem 'pry'
