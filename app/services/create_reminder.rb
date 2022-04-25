# frozen_string_literal: true

require_relative 'notification'

module NotificationTesting
  # Models a secret assignment
  class CreateReminder
    def call(params:)
      # utc_time_obj = Time.local(params['year'], params['month'], params['day'],
      #                           params['hour'], params['min'], 0).getutc
      utc_time_obj = Time.local(params['fixed_year'], params['fixed_month'], params['fixed_day'],
                                params['fixed_hour'], params['fixed_min'], 0).getlocal
      params['fixed_timestamp'] = utc_time_obj
      new_params = params.except('fixed_year', 'fixed_month', 'fixed_day', 'fixed_hour', 'fixed_min')

      # get the related entity
      reminder = Reminder.create(new_params)

      study = Study.where(id: params['owner_study_id']).first
      reminer_title = "#{reminder.title}_#{reminder.id}"
      enabled = study[:status] == 'launched' && reminder.fixed_timestamp > Time.now.utc

      puts "Creating schedule: #{reminer_title}"
      Sidekiq.set_schedule(reminer_title, { 'at' => [reminder.fixed_timestamp],
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
