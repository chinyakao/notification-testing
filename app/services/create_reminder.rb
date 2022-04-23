# frozen_string_literal: true

require_relative 'notification'

module NotificationTesting
  # Models a secret assignment
  class CreateReminder
    def call(params:)
      # utc_time_obj = Time.local(params['year'], params['month'], params['day'],
      #                           params['hour'], params['min'], params['sec']).getutc
      utc_time_obj = Time.local(params['year'], params['month'], params['day'],
                                params['hour'], params['min'], params['sec']).getlocal
      params['reminder_date'] = utc_time_obj
      new_params = params.except('year', 'month', 'day', 'hour', 'min', 'sec')

      # get the related entity
      reminder = Reminder.create(new_params)

      study = Study.where(id: params['owner_study_id']).first
      reminer_title = "#{reminder.title}_#{reminder.id}"
      enabled = study[:status] == 'launched' && reminder.reminder_date > Time.now.utc

      puts "Creating schedule: #{reminer_title}"
      Sidekiq.set_schedule(reminer_title, { 'at' => [reminder.reminder_date],
                                            'class' => 'Workers::SendReminder',
                                            'enabled' => enabled,
                                            'args' => [study.aws_arn,
                                                       reminder.content] })

      reminder
    rescue
      puts 'fail to create reminder'
    end
  end
end
