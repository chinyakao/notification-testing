# frozen_string_literal: true

require_relative 'notification'

module NotificationTesting
  # Models a secret assignment
  class CreateParticipant
    def initialize(config)
      @config = config
      @sns_client = Aws::SNS::Client.new(
        access_key_id: config.AWS_ACCESS_KEY_ID,
        secret_access_key: config.AWS_SECRET_ACCESS_KEY,
        region: config.AWS_REGION
      )
    end

    def call(participant:)
      topic_arn = Study.where(id: participant['owner_study_id']).first.aws_arn
      protocol = participant['contact_type']
      endpoint = participant['contact_info']

      aws_arn = @sns_client.subscribe(topic_arn: topic_arn, protocol: protocol, endpoint: endpoint)[:subscription_arn]
      participant['aws_arn'] = aws_arn
      Participant.create(participant) unless aws_arn.nil?
    rescue
      puts 'fail to create participant'
    end
  end
end
