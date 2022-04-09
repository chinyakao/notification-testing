# frozen_string_literal: true

require_relative 'notification'
require 'rufus-scheduler'

module NotificationTesting
  # This file should be triggered everyday by cron job
  # Services: query db everyday and get the daily reminders which is launched
  class GetDailyReminders
    def initialize(config)
      @scheduler = Rufus::Scheduler.new
      @config = config
      @sns_client = Aws::SNS::Client.new(
        access_key_id: config.AWS_ACCESS_KEY_ID,
        secret_access_key: config.AWS_SECRET_ACCESS_KEY,
        region: config.AWS_REGION
      )
    end

    # def local_running_sys(date)
    #   Time.gm(date.year, date.month, date.day, date.hour, date.min, date.sec)
    # end

    # send a message
    def message_sent?(sns_client, topic_arn, message)
      sns_client.publish(topic_arn: topic_arn, message: message)
    rescue StandardError => e
      puts "Error while sending the message: #{e.message}"
    end

    def call
      reminder_list = Reminder.where(status: 'launched').where { reminder_date >= Time.now.gmtime }.all

      # rufus-scheduler reminders
      # reminder_list.each do |reminder|
      #   notify = "#{reminder.reminder_date} #{reminder.reminder_time}"

      #   @scheduler.in notify do
      #     message = reminder.content
      #     puts 'Message sending.'
      #     if message_sent?(@sns_client, topic_arn, message)
      #       puts "The message: (#{reminder.title}: #{message}) was sent."
      #     else
      #       puts 'The message was not sent. Stopping program.'
      #       exit 1
      #     end
      #   end
      # end
    rescue
      puts 'fail to launch study'
    end
  end
end
