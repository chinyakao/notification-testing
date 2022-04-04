# frozen_string_literal: true

require_relative 'notification'

module NotificationTesting
  # Models a secret assignment
  class CreateReminder
    def call(params:)
      utc_time_obj = Time.local(params['year'], params['month'], params['day'],
                                params['hour'], params['min'], params['sec']).getutc
      params['reminder_date'] = utc_time_obj
      new_params = params.except('year', 'month', 'day', 'hour', 'min', 'sec')

      Reminder.create(new_params)
    rescue
      puts 'fail to create reminder'
    end
  end
end
