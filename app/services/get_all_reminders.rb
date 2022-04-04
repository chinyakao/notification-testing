# frozen_string_literal: true

module NotificationTesting
  # Models a secret reminders
  class GetAllReminders
    def call(owner_study_id:)
      reminder_list = Reminder.where(owner_study_id: owner_study_id).all
      reminder_list.map! { |reminder| GetReminder.new.call(id: reminder.id) }
    rescue
      puts 'fail to read reminders'
    end
  end
end
