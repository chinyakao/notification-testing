# frozen_string_literal: true

require 'sequel'

module NotificationTesting
  module Database
    # Object-Relational Mapper for Members
    class StudyOrm < Sequel::Model(:studys)
      one_to_many :owned_participants,
                  class: :'NotificationTesting::Database::ParticipantOrm',
                  key: :study_id

      one_to_many :owned_reminders,
                  class: :'NotificationTesting::Database::ReminderOrm',
                  key: :study_id

      plugin :timestamps, update_on_create: true

      def self.find_or_create(study_info)
        first(title: study_info[:title]) || create(study_info)
      end
    end
  end
end
