# frozen_string_literal: true

module NotificationTesting
  # Models a secret assignment
  class CreateReminder
    def create_fixed_time(params)
      # utc_time_obj = Time.local(params['year'], params['month'], params['day'],
      #                           params['hour'], params['min'], 0).getutc
      utc_time_obj = Time.local(params['fixed_year'], params['fixed_month'], params['fixed_day'],
                                params['fixed_hour'], params['fixed_min'], 0).getlocal
      params['fixed_timestamp'] = utc_time_obj
      params.except!('repeat_at')
      params
    end

    def create_repeat_every(params)
      case params['repeat_every']
      when 'day'
        '* * *'
      when 'week'
        "* * #{params['repeat_on']}"
      end
    end

    def create_repeat_at(params)
      case params['repeat_at']
      when 'set_time'
        params['repeat_set_time'] = "#{params['repeat_set_time_min']} #{params['repeat_set_time_hour']} #{create_repeat_every(params)}"
      when 'random'
        params['repeat_random_every'] = create_repeat_every(params).to_s
        params['repeat_random_start'] = "#{params['repeat_random_start_hour']}:#{params['repeat_random_start_min']}"
        params['repeat_random_end'] = "#{params['repeat_random_end_hour']}:#{params['repeat_random_end_min']}"
      end
      params
    end

    def call(params:)
      case params['type']
      when 'fixed'
        new_params = create_fixed_time(params)
      when 'repeating'
        new_params = create_repeat_at(params)
      end

      params.except!('fixed_year', 'fixed_month', 'fixed_day', 'fixed_hour', 'fixed_min')
      params.except!('repeat_every', 'repeat_on', 'repeat_set_time_hour', 'repeat_set_time_min',
                     'repeat_random_start_hour', 'repeat_random_start_min',
                     'repeat_random_end_hour', 'repeat_random_end_min')

      # get the related entity
      reminder = Reminder.create(new_params)

      CreateSchedule.new.call(reminder: reminder)

      reminder
    rescue
      puts 'fail to create reminder'
    end
  end
end
