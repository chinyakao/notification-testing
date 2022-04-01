# frozen_string_literal: true

require 'json'

module NotificationTesting
  # Models a secret assignment
  class GetParticipantDetail

    def call(participant:)
      modified_string = participant[:column_value]
        .gsub(/:(\w+)/){"\"#{$1}\""}
        .gsub('=>', ':')
        .gsub("nil", "null")
      participant[:column_value]= JSON.parse(modified_string)
    rescue
      participant[:column_value]
    end
  end
end
