# frozen_string_literal: true

require 'rake/testtask'
require './require_app'

task :default do
  puts `rake -T`
end

task :print_env do
  puts "Environment: #{ENV['RACK_ENV'] || 'development'}"
end

desc 'Run application console (pry)'
task :console => :print_env do
  sh 'pry -r ./test_load_all'
end

namespace :db do
  task :load do
    require_app(nil) # loads config code files only
    require 'sequel'

    Sequel.extension :migration
    @app = NotificationTesting::App
  end

  task :load_models => :load do
    require_app(%w[models services])
  end

  desc 'Run migrations'
  task :migrate => [:load, :print_env] do
    puts 'Migrating database to latest'
    Sequel::Migrator.run(@app.DB, 'app/database/migrations')
  end

  desc 'Destroy data in database; maintain tables'
  task :delete => :load do
    NotificationTesting::Study.dataset.destroy
  end

  desc 'Delete dev or test database file'
  task :drop => :load do
    if @app.environment == :production
      puts 'Cannot wipe production database!'
      return
    end

    db_filename = "app/database/store/#{NotificationTesting::App.environment}.db"
    FileUtils.rm(db_filename)
    puts "Deleted #{db_filename}"
  end

  task :reset_seeds => :load_models do
    @app.DB[:schema_seeds].delete if @app.DB.tables.include?(:schema_seeds)
    NotificationTesting::Study.dataset.destroy
  end

  desc 'Seeds the development database'
  task :seed => [:load_models] do
    require 'sequel/extensions/seed'
    Sequel::Seed.setup(:development)
    Sequel.extension :seed
    Sequel::Seeder.apply(@app.DB, 'app/database/seeds')
  end

  desc 'Delete all data and reseed'
  task reseed: [:reset_seeds, :seed]
end

namespace :run do
  # Run in development mode
  task :dev do
    sh 'rackup -p 9292'
  end
end

namespace :worker do
  namespace :run do
    desc 'Run the background worker for scheduling job in development mode'
    task :dev => :config do
      sh 'RACK_ENV=development bundle exec sidekiq -r ./workers/jobs_scheduler_dev.rb'
    end

    desc 'Run the background worker for scheduling job in testing mode'
    task :test => :config do
      sh 'RACK_ENV=development bundle exec sidekiq -r ./workers/jobs_scheduler_test.rb'
    end

    desc 'Run the background worker for scheduling job in production mode'
    task :production => :config do
      sh 'RACK_ENV=development bundle exec sidekiq -r ./workers/jobs_scheduler.rb'
    end
  end
end
