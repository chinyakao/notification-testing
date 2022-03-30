# frozen_string_literal: true

require 'rake/testtask'
require './require_app'

task :default do
  puts `rake -T`
end

desc 'Run tests once'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/*_spec.rb'
  t.warning = false
end

desc 'Keep rerunning tests upon changes'
task :respec do
  sh "rerun -c 'rake spec' --ignore 'coverage/*'"
end

desc 'Keep restarting web app upon changes'
task :rerack do
  sh "rerun -c rackup --ignore 'coverage/*'"
end

namespace :db do
  # task :config do
  #   require 'sequel'
  #   require_relative 'config/environment' # load config info
  #   # require_relative 'spec/helpers/database_helper'

  #   def app() = NotificationTesting::App
  # end

  task :load do
    require_app(nil) # loads config code files only
    require 'sequel'
    # require_relative 'config/environment'

    Sequel.extension :migration
    @app = NotificationTesting::App
  end

  task :load_models => :load do
    require_app(%w[models])
  end

  desc 'Run migrations'
  task :migrate => :load do
    Sequel.extension :migration
    puts "Migrating #{@app.environment} database to latest"
    Sequel::Migrator.run(@app.DB, 'app/infrastructure/database/migrations')
  end

  desc 'Wipe records from all tables'
  task :wipe => :load do
    if @app.environment == :production
      puts 'Do not damage production database!'
      return
    end

    DatabaseHelper.wipe_database
  end

  desc 'Delete dev or test database file (set correct RACK_ENV)'
  task :drop => :load do
    if @app.environment == :production
      puts 'Do not damage production database!'
      return
    end

    FileUtils.rm(NotificationTesting::App.config.DB_FILENAME)
    puts "Deleted #{NotificationTesting::App.config.DB_FILENAME}"
  end

  task :reset_seeds => :load_models do
    @app.DB[:schema_seeds].delete if @app.DB.tables.include?(:schema_seeds)
    NotificationTesting::Account.dataset.destroy
  end

  desc 'Seeds the development database'
  task :seed => [:load_models] do
    require 'sequel/extensions/seed'
    Sequel::Seed.setup(:development)
    Sequel.extension :seed
    Sequel::Seeder.apply(@app.DB, 'app/infrastructure/database/seeds')
  end

  desc 'Delete all data and reseed'
  task reseed: [:reset_seeds, :seed]
end

desc 'Run application console'
task :console do
  sh 'pry -r ./init'
end
