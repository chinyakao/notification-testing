# frozen_string_literal: true

require 'json'
require 'sequel'

module NotificationTesting
  # Models a secret assignment
  class Reminder < Sequel::Model
    many_to_one :owner_study, class: :'NotificationTesting::Study'

    plugin :timestamps

    def local_running_sys(date)
      Time.gm(date.year, date.month, date.day, date.hour, date.min, date.sec)
    end

    def check_dateandtime(type, fixed_timestamp,repeat_at, repeat_set_time, repeat_random_every)
      case type
      when 'fixed'
        fixed_timestamp.getlocal.strftime('%Y-%m-%d %H:%M:%S')
      when 'repeating'
        case repeat_at
        when 'set_time'
          repeat_set_time.to_s
        when 'random'
          repeat_random_every.to_s
        end
      end
    end

    # rubocop:disable Metrics/MethodLength
    def to_h
      {
        type: 'reminder',
        attributes: {
          id: id,
          type: type,
          title: title,
          # fixed_timestamp: local_running_sys(fixed_timestamp).getlocal.strftime('%Y-%m-%d %H:%M:%S'),
          dateandtime: check_dateandtime(type, fixed_timestamp, repeat_at, repeat_set_time, repeat_random_every),
          content: content,
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
