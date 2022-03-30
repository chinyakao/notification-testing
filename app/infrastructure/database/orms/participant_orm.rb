# frozen_string_literal: true

require 'sequel'

module NotificationTesting
  module Database
    # Object Relational Mapper for Participant Entities
    class ParticipantOrm < Sequel::Model(:participants)
      many_to_one :study,
                  class: :'NotificationTesting::Database::StudyOrm'

      plugin :timestamps, update_on_create: true
    end
  end
end
