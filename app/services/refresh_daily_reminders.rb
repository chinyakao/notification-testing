# frozen_string_literal: true

module NotificationTesting
  # This file should be triggered everyday by 
  # Services: query db everyday and get the daily reminders which is launched
  class RefeshDailyReminders
    def initialize(config)
      # @scheduler = Rufus::Scheduler.new
      # @config = config
      # @sns_client = Aws::SNS::Client.new(
      #   access_key_id: config.AWS_ACCESS_KEY_ID,
      #   secret_access_key: config.AWS_SECRET_ACCESS_KEY,
      #   region: config.AWS_REGION
      # )
    end

    def call
      Study.where(id: study_id).update(status: 'launched')
      study = GetStudy.new.call(id: study_id)
      reminder_list = GetAllReminders.new.call(owner_study_id: study_id)
      reminder_list.map { |reminder| Reminder.where(id: reminder.id).update(status: 'launched') }

    rescue
      puts 'fail to launch study'
    end
  end
end
