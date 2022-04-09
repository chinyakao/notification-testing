# frozen_string_literal: true

require_relative 'notification'

module NotificationTesting
  # Models a secret assignment
  class ConfirmParticipantStatus
    def initialize(config)
      @config = config
      @sns_resource = Aws::SNS::Resource.new(
        access_key_id: config.AWS_ACCESS_KEY_ID,
        secret_access_key: config.AWS_SECRET_ACCESS_KEY,
        region: config.AWS_REGION
      )
    end

    def call(study_id:)
      topic_arn = Study.where(id: study_id).first.aws_arn
      topic = @sns_resource.topic(topic_arn)

      topic.subscriptions.map do |subscription|
        next if subscription.arn == 'PendingConfirmation'

        subscription_attr = subscription.attributes
        update_participant = Participant.where(owner_study_id: study_id,
                                               confirm_status: false,
                                               contact_info: subscription_attr['Endpoint']).first

        next if update_participant.nil?

        Participant.where(id: update_participant.id)
                   .update(confirm_status: true,
                           aws_arn: subscription.arn)
      end
    end
  end
end
