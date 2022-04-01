# frozen_string_literal: true

require_relative 'notification'
require 'rufus-scheduler'

module NotificationTesting
  # Models a secret assignment
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
      topic_arn = GetStudy.new.call(id: study_id).aws_arn
      reminder_list = GetAllReminders.new.call(owner_study_id: study_id)
      study = Study.where(id: study_id).update(status: 'start')
      
      # reminder
      reminder_list.each do |reminder|
        notify = "#{reminder.reminder_date} #{reminder.reminder_time}"
        
        @scheduler.in notify do
          message = reminder.content

          puts 'Message sending.'
          if message_sent?(@sns_client, topic_arn, message)
            
            puts "The message: (#{reminder.reminder_code}: #{message}) was sent."
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
