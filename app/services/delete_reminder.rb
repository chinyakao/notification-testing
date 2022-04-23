# frozen_string_literal: true

module NotificationTesting
  # Models a secret assignment
  class DeleteReminder
    def call(id:)
      reminder = Reminder.where(id: id).first
      reminer_title = "#{reminder.title}_#{reminder.id}"

      # fixed
      puts "Deleting schedule: #{reminer_title}"
      Sidekiq.remove_schedule(reminer_title)

      Reminder.where(id: id).destroy
    rescue
      puts 'fail to delete reminder'
    end
  end
end
