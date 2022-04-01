# frozen_string_literal: true

require 'json'
require 'aws-sdk-sns'

module NotificationTesting
  class Notification
    def initialize(config)
      @config = config
      @sns_client = Aws::SNS::Client.new(
        access_key_id: config.AWS_ACCESS_KEY_ID,
        secret_access_key: config.AWS_SECRET_ACCESS_KEY,
        region: config.AWS_REGION
      )
      # @queue = Aws::SQS::Queue.new(url: queue_url, client: sqs)
    end

    # create a topic
    def topic_created(sns_client, topic_name)
      topic_arn = @sns_client.create_topic(name: topic_name)
      topic_arn
    rescue StandardError => e
      puts "Error while creating the topic named '#{topic_name}': #{e.message}"
    end

    # create a subscription
    def subscription_created?(sns_client, topic_arn, protocol, endpoint)
      @sns_client.subscribe(topic_arn: topic_arn, protocol: protocol, endpoint: endpoint)
    rescue StandardError => e
      puts "Error while creating the subscription: #{e.message}"
    end

    # send a message
    def message_sent?(sns_client, topic_arn, message)
      @sns_client.publish(topic_arn: topic_arn, message: message)
    rescue StandardError => e
      puts "Error while sending the message: #{e.message}"
    end
  end
end
