# frozen_string_literal: true

require 'cronex'
require 'json'
require 'sequel'
require 'time'

module NotificationTesting
  # Models a secret assignment
  class Reminder < Sequel::Model
    many_to_one :owner_study, class: :'NotificationTesting::Study'

    plugin :timestamps

    def local_running_sys(date)
      Time.gm(date.year, date.month, date.day, date.hour, date.min, date.sec)
    end

    def time_parse(time)
      Time.parse(time).strftime('%H:%M')
    end

    def make_dateandtime
      case type
      when 'fixed'
        fixed_timestamp.getlocal.strftime('%Y-%m-%d %H:%M')
        # local_running_sys(fixed_timestamp).getlocal.strftime('%Y-%m-%d %H:%M:%S')
      when 'repeating'
        case repeat_at
        when 'set_time'
          Cronex::ExpressionDescriptor.new(repeat_set_time).description
        when 'random'
          repeat = Cronex::ExpressionDescriptor.new("0 0 #{repeat_random_every}").description
          repeat = repeat.split('only').length > 1 ? repeat.split('only')[1] : 'on Everyday'
          "random between #{time_parse(repeat_random_start)} to #{time_parse(repeat_random_end)}, #{repeat}"
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
          dateandtime: make_dateandtime,
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
