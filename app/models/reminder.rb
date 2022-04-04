# frozen_string_literal: true

require 'json'
require 'sequel'

module NotificationTesting
  # Models a secret assignment
  class Reminder < Sequel::Model
    many_to_one :owner_study, class: :'NotificationTesting::Study'

    plugin :timestamps
    # plugin :whitelist_security
    # set_allowed_columns :course_name

    # rubocop:disable Metrics/MethodLength
    def to_h
      {
        type: 'reminder',
        attributes: {
          id: id,
          type: type,
          reminder_code: reminder_code,
          reminder_date: reminder_date.getlocal.strftime("%Y-%m-%d %H:%M:%S"),
          content: content,
          status: status,
          owner_study: owner_study
        }
      }
    end
    # rubocop:enable Metrics/MethodLength

    def full_details
      to_h.merge(
        relationships: {
          owner_study: owner_study
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
