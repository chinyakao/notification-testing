# frozen_string_literal: true

require_relative 'notification'
require 'rufus-scheduler'

module NotificationTesting
  # Services: change the study's status and the related reminders' status
  class LaunchStudy
    def initialize(config)
      @scheduler = Rufus::Scheduler.new
      @config = config
      @sns_client = Aws::SNS::Client.new(
        access_key_id: config.AWS_ACCESS_KEY_ID,
        secret_access_key: config.AWS_SECRET_ACCESS_KEY,
        region: config.AWS_REGION
      )
    end

    # send a message
    def message_sent?(sns_client, topic_arn, message)
      sns_client.publish(topic_arn: topic_arn, message: message)
    rescue StandardError => e
      puts "Error while sending the message: #{e.message}"
    end

    def local_running_sys(date)
      Time.gm(date.year, date.month, date.day, date.hour, date.min, date.sec)
    end

    def call(study_id:)
      reminder_list = Reminder.where(owner_study_id: study_id).all
      reminder_list.map { |reminder| Reminder.where(id: reminder.id).update(status: 'launched') }
      Study.where(id: study_id).update(status: 'launched')
      topic_arn = Study.where(id: study_id).first.aws_arn

      # rufus-scheduler reminders
      reminder_list.each do |reminder|
        notify = "#{local_running_sys(reminder.reminder_date).getlocal.strftime("%Y/%m/%d %H:%M:%S")}"
        # notify = "#{reminder.reminder_date.getlocal.strftime("%Y/%m/%d %H:%M:%S")}"

        @scheduler.in notify do
          message = reminder.content
          puts 'Message sending.'
          if message_sent?(@sns_client, topic_arn, message)
            puts "The message: (#{reminder.title}: #{message}) was sent."
          else
            puts 'The message was not sent. Stopping program.'
            exit 1
          end
        end
      end
    rescue
      puts 'fail to launch study'
    end
  end
end
