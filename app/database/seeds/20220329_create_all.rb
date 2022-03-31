# frozen_string_literal: true

# NOT FINISH YET

Sequel.seed(:development) do
  def run
    puts 'Seeding studies, participants, reminders'
    create_studies
    create_owned_participants
    create_owned_reminders
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
STUDIES_INFO = YAML.load_file("#{DIR}/study_seeds.yml")
OWNER_PARTICIPANTS_INFO = YAML.load_file("#{DIR}/owner_participants.yml")
OWNER_REMINDERS_INFO = YAML.load_file("#{DIR}/owner_reminders.yml")
PARTICIPANTS_INFO = YAML.load_file("#{DIR}/participant_seeds.yml")
REMINDERS_INFO = YAML.load_file("#{DIR}/reminder_seeds.yml")


def create_studies
  STUDIES_INFO.each do |study_info|
    NotificationTesting::Study.create(study_info)
  end
end

def create_owned_participants
  OWNER_PARTICIPANTS_INFO.each do |owner_study|
    study = NotificationTesting::Study.first(title: owner_study['title'])
    owner_study['participant_code'].each do |participant_code|
      participant_data = PARTICIPANTS_INFO.find { |participant| participant['participant_code'] == participant_code }
      study.add_owned_participant(participant_data)
    end
  end
end

def create_owned_reminders
  OWNER_REMINDERS_INFO.each do |owner_study|
    study = NotificationTesting::Study.first(title: owner_study['title'])
    owner_study['reminder_code'].each do |reminder_code|
      reminder_data = REMINDERS_INFO.find { |reminder| reminder['reminder_code'] == reminder_code }
      study.add_owned_reminder(reminder_data)
    end
  end
end
