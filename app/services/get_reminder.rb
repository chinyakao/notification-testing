# frozen_string_literal: true

module NotificationTesting
  # Models a secret reminder
  class GetReminder

    def call(id:)
      Reminder.where(id: id).first
    rescue
      puts 'fail to read reminder'
    end
  end
end