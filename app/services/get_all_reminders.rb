# frozen_string_literal: true

module NotificationTesting
  # Models a secret reminders
  class GetAllReminders

    def call(owner_study_id:)
      Reminder.where(owner_study_id: owner_study_id).all
    rescue
      puts 'fail to read reminders'
    end
  end
end
