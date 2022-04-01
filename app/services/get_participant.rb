# frozen_string_literal: true

module NotificationTesting
  # Models a secret participant
  class GetParticipant

    def call(id:)
      Participant.where(id: id).first
    rescue
      puts 'fail to read participant'
    end
  end
end