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
      reminder_list = NotificationTesting::Reminder.where(repeat_at: 'random').all

      return if reminder_list.empty?

      reminder_list.each do |reminder|
        cron = NotificationTesting::CreateSchedule.new.create_repeat_random_schedule(reminder)

        reminder_title = "#{reminder.title}_#{reminder.id}"
        schedule = Sidekiq.get_schedule(reminder_title)

        next if schedule.nil?

        Sidekiq.set_schedule(reminder_title, { 'cron' => cron,
                                               'class' => 'Workers::SendReminder',
                                               'enabled' => schedule['enabled'],
                                               'args' => schedule['args'] })
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
