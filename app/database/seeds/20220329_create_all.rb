# frozen_string_literal: true

# NOT FINISH YET

Sequel.seed(:development) do
  def run
    puts 'Seeding studys, participants, reminders'
    create_studys
    create_participants
    create_reminders
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
STUDYS_INFO = YAML.load_file("#{DIR}/study_seeds.yml")
PARTICIPANTS_INFO = YAML.load_file("#{DIR}/participant_seeds.yml")
REMINDERS_INFO = YAML.load_file("#{DIR}/reminder_seeds.yml")


def create_studys
  STUDYS_INFO.each do |study_info|
    NotificationTesting::Study.create(study_info)
  end
end

def create_participants
  PARTICIPANTS_INFO.each do |participant_info|
    NotificationTesting::Participant.create(participant_info)
  end
end

def create_reminders
  REMINDERS_INFO.each do |reminder_info|
    NotificationTesting::Reminder.create(reminder_info)
  end
end
