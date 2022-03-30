# frozen_string_literal: true

require 'sequel'

module NotificationTesting
  module Database
    # Object Relational Mapper for Reminder Entities
    class ReminderOrm < Sequel::Model(:reminders)
      many_to_one :study,
                  class: :'NotificationTesting::Database::StudyOrm'

      plugin :timestamps, update_on_create: true
    end
  end
end