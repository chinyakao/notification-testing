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

    def call(study_id:)
      reminder_list = GetAllReminders.new.call(owner_study_id: study_id)
      reminder_list.map { |reminder| Reminder.where(id: reminder.id).update(status: 'launched') }
      Study.where(id: study_id).update(status: 'launched')
    rescue
      puts 'fail to launch study'
    end
  end
end
