# frozen_string_literal: true
require 'figaro'
require 'aws-sdk-sns'
require 'sidekiq'
require 'sidekiq-scheduler'
require 'sidekiq/web'

module Workers
  # Testing sidekiq
  class WorkWell
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

    include Sidekiq::Worker

    def perform
      puts 'work well'
    end
  end

  # # A job sending a reminder through aws sns
  # class SendReminder
  #   include Sidekiq::Worker

  #   # Environment variables setup
  #   # Figaro.application = Figaro::Application.new(
  #   #   environment: ENV['RACK_ENV'] || 'development',
  #   #   path: File.expand_path('config/secrets.yml')
  #   # )
  #   # Figaro.load
  #   # def self.config() = Figaro.env

  #   def perform(access_key_id, secret_access_key, region, topic_arn, message)
  #     puts 'Message sending.'
  #     # sns_client = Aws::SNS::Client.new(
  #     #   access_key_id: access_key_id,
  #     #   secret_access_key: secret_access_key,
  #     #   region: region
  #     # )
  #     # sns_client.publish(topic_arn: topic_arn, message: message)

  #     puts "The message: #{message} was sent."
  #   end
  # end
end
