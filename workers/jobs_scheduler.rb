# frozen_string_literal: true

require 'figaro'
require 'aws-sdk-sns'
require 'sidekiq'
require 'sidekiq-scheduler'
require 'sidekiq/web'
require_relative '../require_app'

# Workers
module Workers
  # Testing sidekiq
  class WorkWell
    include Sidekiq::Worker
    # require_app

    def perform
      # reminder = NotificationTesting::Reminder.where(id: 1).first
      # puts reminder
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

  # a static cron job (everyday 00:05) query random reminder and set the random time for that day
  class UpdateRandomReminder
    include Sidekiq::Worker
    require_app

    def perform
      reminder_list = NotificationTesting::Reminder.where(repeat_set_random: 'random').all
      reminder_list.map do |reminder|
        r_start = Time.parse(reminder.repeat_random_start) # "10:00"
        r_end = Time.parse(reminder.repeat_random_end) # "12:00"
        r_result = r_start + rand(r_end - r_start)
        reminder.repeat_random_every[0] = r_result.min.to_s
        reminder.repeat_random_every[3] = r_result.hour.to_s

        reminer_title = "#{reminder.title}_#{reminder.id}"
        Sidekiq.set_schedule(reminer_title, { 'cron' => repeat_random_every })
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
