# frozen_string_literal: true

require 'time'

module NotificationTesting
  # Models a secret assignment
  class CreateSchedule
    def create_repeat_random_schedule(reminder)
      r_start = Time.parse(reminder.repeat_random_start) # "10:00"
      r_end = Time.parse(reminder.repeat_random_end) # "12:00"
      r_result = r_start + rand(r_end - r_start)
      "#{r_result.min} #{r_result.hour} #{reminder.repeat_random_every}"
    end

    def call(reminder:)
      study = Study.where(id: reminder.owner_study_id).first
      reminer_title = "#{reminder.title}_#{reminder.id}"

      puts "Creating schedule: #{reminer_title}"
      case reminder.type
      when 'fixed'
        # expired or not
        if reminder.fixed_timestamp > Time.now.utc
          puts "Enabling schedule: #{reminer_title}"
        else
          puts "Disabling schedule: #{reminer_title}"
        end

        enabled = study[:status] == 'launched' && reminder.fixed_timestamp > Time.now.utc
        Sidekiq.set_schedule(reminer_title, { 'at' => [reminder.fixed_timestamp],
                                              'class' => 'Jobs::SendReminder',
                                              'enabled' => enabled,
                                              'args' => [study.aws_arn,
                                                         reminder.content] })
      when 'repeating'
        enabled = study[:status] == 'launched'
        case reminder.repeat_at
        when 'set_time'
          Sidekiq.set_schedule(reminer_title, { 'cron' => [reminder.repeat_set_time],
                                                'class' => 'Jobs::SendReminder',
                                                'enabled' => enabled,
                                                'args' => [study.aws_arn,
                                                           reminder.content] })
        when 'random'
          Sidekiq.set_schedule(reminer_title, { 'cron' => create_repeat_random_schedule(reminder),
                                                'class' => 'Jobs::SendReminder',
                                                'enabled' => enabled,
                                                'args' => [study.aws_arn,
                                                           reminder.content] })
        end
      end
      reminder
    rescue
      puts 'fail to create reminder'
    end
  end
end
