# frozen_string_literal: true

require_relative 'notification'
require 'rufus-scheduler'

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
      reminder_list.map { |reminder| Reminder.where(id: reminder.id).update(status: 'design') }
      Study.where(id: study_id).update(status: 'design')
    rescue
      puts 'fail to stop study'
    end
  end
end
