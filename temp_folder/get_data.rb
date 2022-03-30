# frozen_string_literal: false

require 'yaml'

DATA = {
  participants: YAML.load(File.read('/Users/rileykao/Desktop/notification-testing /app/infrastructure/gateways/seeds/participant_seeds.yml')),
  reminders: YAML.load(File.read('/Users/rileykao/Desktop/notification-testing /app/infrastructure/gateways/seeds/reminder_seeds.yml')),
  studys: YAML.load(File.read('/Users/rileykao/Desktop/notification-testing /app/infrastructure/gateways/seeds/study_seeds.yml'))
}.freeze

TITLE = 'This is first study title'

DATA[:studys].map do |study|
  if study['title'] == TITLE
    target = study
    puts target
  end
end
