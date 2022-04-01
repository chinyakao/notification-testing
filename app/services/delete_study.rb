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
      topic = @sns_resource.topic(study.aws_arn)
      topic.subscriptions.map{|subscription| subscription.delete }
      topic.delete
      Study.where(id: id).destroy
    rescue
      puts 'fail to delete study'
    end
  end
end
