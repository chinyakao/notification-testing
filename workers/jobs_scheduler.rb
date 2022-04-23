# frozen_string_literal: true

require 'figaro'
require 'aws-sdk-sns'
require 'sidekiq'
require 'sidekiq-scheduler'
require 'sidekiq/web'

# Workers
module Workers
  # Testing sidekiq
  class WorkWell
    include Sidekiq::Worker

    def perform
      puts 'work well'
    end
  end

  # Worker config
  class App
    # Environment variables setup
    Figaro.application = Figaro::Application.new(
      environment: ENV['RACK_ENV'] || 'development',
      path: File.expand_path('config/secrets.yml')
    )
    Figaro.load
    def self.config() = Figaro.env

    Sidekiq.configure_server do |config|
      config.on(:startup) do
        # config.redis = { url: ENV['REDIS_URL'] } # no need to define
        Sidekiq.schedule = YAML.load_file(File.expand_path('workers/sidekiq_scheduler.yml'))
        SidekiqScheduler::Scheduler.instance.reload_schedule!
      end
    end
  end

  # A job sending a reminder through aws sns
  class SendReminder
    include Sidekiq::Worker

    def perform(topic_arn, message)
      puts 'Message sending.'

      sns_client = Aws::SNS::Client.new(
        access_key_id: App.config.AWS_ACCESS_KEY_ID,
        secret_access_key: App.config.AWS_SECRET_ACCESS_KEY,
        region: App.config.AWS_REGION
      )

      sns_client.publish(topic_arn: topic_arn, message: message)

      puts "The message: #{message} was sent."
    end
  end
end
