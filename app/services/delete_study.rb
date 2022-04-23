# frozen_string_literal: true

require_relative 'notification'

module NotificationTesting
  # Models a secret assignment
  class DeleteStudy
    def initialize(config)
      @config = config
      @sns_resource = Aws::SNS::Resource.new(
        access_key_id: config.AWS_ACCESS_KEY_ID,
        secret_access_key: config.AWS_SECRET_ACCESS_KEY,
        region: config.AWS_REGION
      )
    end

    def call(id:)
      study = Study.where(id: id).first

      # AWS: delete subscription(participants) and topic(study)
      topic = @sns_resource.topic(study.aws_arn)
      unless topic.subscriptions.first.nil?
        topic.subscriptions.each do |subscribe|
          subscribe.delete unless subscribe.arn == 'PendingConfirmation'
        end
      end
      topic.delete

      # Schedule: delete related schedule
      reminder_list = Reminder.where(owner_study_id: id).all
      reminder_list.map { |reminder| DeleteReminder.new.call(id: reminder.id) }

      # DB: delete related entity in database
      Study.where(id: id).destroy
    rescue
      puts 'fail to delete study'
    end
  end
end
