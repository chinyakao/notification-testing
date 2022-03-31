# frozen_string_literal: true

require 'json'
require 'sequel'

module NotificationTesting
  # Models a dashboard
  class Study < Sequel::Model
    one_to_many :owned_participants, class: :'NotificationTesting::Participant', key: :owner_study_id

    one_to_many :owned_reminders, class: :'NotificationTesting::Reminder', key: :owner_study_id

    
    plugin :association_dependencies,
            owned_participants: :destroy,
            owned_reminders: :destroy

    # plugin :whitelist_security
    # set_allowed_columns :username, :email, :password

    plugin :timestamps, update_on_create: true

    def participants
      owned_participants
    end

    def reminders
      owned_reminders
    end

    def to_json(options = {})
      JSON(
        {
          type: 'study',
          attributes: {
            title: title,
            aws_arn: aws_arn
          }
        }, options
      )
    end
  end
end
