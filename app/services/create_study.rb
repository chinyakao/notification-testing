# frozen_string_literal: true

require_relative 'notification'

module NotificationTesting
  # Models a secret assignment
  class CreateStudy

    def initialize(config)
      @config = config
      @sns_client = Aws::SNS::Client.new(
        access_key_id: config.AWS_ACCESS_KEY_ID,
        secret_access_key: config.AWS_SECRET_ACCESS_KEY,
        region: config.AWS_REGION
      )
    end

    def call(title:)
      study_arn = @sns_client.create_topic(name: title)[:topic_arn]
      Study.create(title: title, aws_arn: study_arn)
    rescue
      puts 'fail to create study'
    end
  end
end
