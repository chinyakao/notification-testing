# frozen_string_literal: true

require_relative 'notification'

module NotificationTesting
  # Models a secret assignment
  class DeleteParticipant

    def initialize(config)
      @config = config
      @sns_resource = Aws::SNS::Resource.new(
        access_key_id: config.AWS_ACCESS_KEY_ID,
        secret_access_key: config.AWS_SECRET_ACCESS_KEY,
        region: config.AWS_REGION
      )
    end

    def call(id:)
      participant = Participant.where(id: id).first
      # TODO: confirm_status: "pending comfirm"
      subscription = @sns_resource.subscription(participant.aws_arn).delete

      Participant.where(id: id).destroy if subscription.empty?
    rescue
      puts 'fail to create participant'
    end
  end
end
