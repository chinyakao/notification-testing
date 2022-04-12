# frozen_string_literal: true

require 'aws-sdk-sns'
require 'sidekiq-scheduler'

module Jobs
  # Testing sidekiq
  class WorkWell
    include Sidekiq::Worker

    def perform
      puts 'work well'
    end
  end

  # A job sending a reminder through aws sns
  class SendReminder
    include Sidekiq::Worker

    def perform(access_key_id, secret_access_key, region, topic_arn, message)
      puts 'Message sending.'
      sns_client = Aws::SNS::Client.new(
        access_key_id: access_key_id,
        secret_access_key: secret_access_key,
        region: region
      )
      sns_client.publish(topic_arn: topic_arn, message: message)

      puts 'The message was sent.'
    end
  end
end
