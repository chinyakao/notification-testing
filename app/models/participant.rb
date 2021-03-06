# frozen_string_literal: true

require 'json'
require 'sequel'

module NotificationTesting
  # Models a secret assignment
  class Participant < Sequel::Model
    many_to_one :owner_study, class: :'NotificationTesting::Study'

    plugin :timestamps
    plugin :uuid, field: :id

    # rubocop:disable Metrics/MethodLength
    def to_h
      {
        type: 'participant',
        attributes: {
          id: id,
          nickname: nickname,
          details: string_parse_to_hash(details),
          contact_type: contact_type,
          contact_info: contact_info
        }
      }
    end
    # rubocop:enable Metrics/MethodLength

    def full_details
      to_h.merge(
        relationships: {
          owner_study: owner_study,
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
