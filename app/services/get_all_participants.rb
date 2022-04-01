# frozen_string_literal: true

module NotificationTesting
  # Models a secret participants
  class GetAllParticipants

    def call(owner_study_id:)
      Participant.where(owner_study_id: owner_study_id).all
    rescue
      puts 'fail to read participants'
    end
  end
end
