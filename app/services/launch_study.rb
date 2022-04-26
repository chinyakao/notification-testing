# frozen_string_literal: true

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
      study = Study.where(id: study_id).update(status: 'launched')

      # scheduler reminders
      reminder_list.map do |reminder|
        CreateSchedule.new.call(reminder: reminder)
      end
      study
    rescue
      puts 'fail to launch study'
    end
  end
end
