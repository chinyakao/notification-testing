# frozen_string_literal: true

module NotificationTesting
  # Models a secret reminder
  class GetReminder
    def call(id:)
      reminder = Reminder.where(id: id).first.full_details
    rescue
      puts 'fail to read reminder'
    end
  end
end
