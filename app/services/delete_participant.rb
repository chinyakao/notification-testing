# frozen_string_literal: true

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

      # when participant is pending in DB
      if participant.aws_arn == 'pending confirmation'
        # check AWS for updated and cannot delete the pending participant
        # If research/participant gave the wrong the contact info, only can update the participant entity
        # TODO: update the participant entity
        ConfirmParticipantStatus.new(@config).call(study_id: participant.owner_study_id)
        puts 'INFO: You cannot delete pending participant'
        puts 'INFO: Update and wait for the confirm status'
        puts 'INFO: Or deleting the pending participant by deleting the whole study'
      else
        @sns_resource.subscription(participant.aws_arn).delete
        Participant.where(id: id).destroy
      end
    rescue
      puts 'fail to delete participant'
    end
  end
end
