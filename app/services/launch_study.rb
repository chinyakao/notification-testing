# frozen_string_literal: true

require_relative 'notification'
require 'sidekiq-scheduler'

module NotificationTesting
  # Services: change the study's status and the related reminders' status
  class LaunchStudy
    def initialize(config)
      @config = config
      @sns_client = Aws::SNS::Client.new(
        access_key_id: config.AWS_ACCESS_KEY_ID,
        secret_access_key: config.AWS_SECRET_ACCESS_KEY,
        region: config.AWS_REGION
      )
    end

    def call(study_id:)
      reminder_list = Reminder.where(owner_study_id: study_id).all
      topic_arn = Study.where(id: study_id).first.aws_arn

      # scheduler reminders
      reminder_list.map do |reminder|
        # expired or not
        next unless reminder.reminder_date > Time.now.utc

        reminer_title = "#{reminder.title}_#{reminder.id}"
        puts "Create scheduler: #{reminer_title}"

        # fixed reminder
        Sidekiq.set_schedule(reminer_title, { 'at' => [reminder.reminder_date],
                                              'class' => 'Workers::SendReminder',
                                              'enabled' => true,
                                              'args' => [topic_arn,
                                                         reminder.content] })
      end
      Study.where(id: study_id).update(status: 'launched')
    rescue
      puts 'fail to launch study'
    end
  end
end
