# frozen_string_literal: true

require 'json'

module NotificationTesting
  # Models a secret assignment
  class GetParticipantDetail

    def call(participant:)
      modified_string = participant[:details]
        .gsub(/:(\w+)/){"\"#{$1}\""}
        .gsub('=>', ':')
        .gsub("nil", "null")
      participant[:details]= JSON.parse(modified_string)
    rescue
      participant[:details]
    end
  end
end
