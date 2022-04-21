# frozen_string_literal: true

require_relative 'notification'
require 'rufus-scheduler'
require 'sidekiq-scheduler'
require 'sidekiq/api'

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

    def local_running_sys(date)
      Time.gm(date.year, date.month, date.day, date.hour, date.min, date.sec)
    end

    def call(study_id:)
      reminder_list = Reminder.where(owner_study_id: study_id).all

      # scheduler reminders
      reminder_list.each do |reminder|
        reminer_title = "#{reminder.title}_#{reminder.id}"
        # reminder_time = local_running_sys(reminder.reminder_date).getlocal.strftime('%Y/%m/%d %H:%M:%S')
        reminder_time = reminder.reminder_date.getlocal.strftime('%Y/%m/%d %H:%M:%S')

        # fixed
        Sidekiq.set_schedule(reminer_title, { 'at' => [reminder_time],
                                              'class' => 'Workers::SendReminder',
                                              'enabled' => false })
      end
      Study.where(id: study_id).update(status: 'design')
    rescue
      puts 'fail to stop study'
    end
  end
end
