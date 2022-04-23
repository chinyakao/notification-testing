# frozen_string_literal: true

require 'sidekiq-scheduler'

module NotificationTesting
  # Models a secret assignment
  class StopStudy
    def initialize(config)
      @scheduler = Rufus::Scheduler.new
      @config = config
      @sns_client = Aws::SNS::Client.new(
        access_key_id: config.AWS_ACCESS_KEY_ID,
        secret_access_key: config.AWS_SECRET_ACCESS_KEY,
        region: config.AWS_REGION
      )
    end

    def call(study_id:)
      reminder_list = Reminder.where(owner_study_id: study_id).all

      # scheduler reminders
      reminder_list.each do |reminder|
        reminer_title = "#{reminder.title}_#{reminder.id}"

        # fixed
        puts "Disabling schedule: #{reminer_title}"
        Sidekiq.set_schedule(reminer_title, { 'class' => 'Workers::SendReminder',
                                              'enabled' => false })
      end
      Study.where(id: study_id).update(status: 'design')
    rescue
      puts 'fail to stop study'
    end
  end
end
