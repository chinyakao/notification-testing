# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:reminders) do
      primary_key :id
      foreign_key :owner_study_id, :studies, type: :uuid

      String      :type, default: 'fixed'
      String      :title, default: 'study_reminder', null: false
      Time        :fixed_timestamp, default: Time.now
      String      :content, default: 'This is a reminder message'
      String      :reminder_tz # reminder's timezone offset (seconds) eg. 32400 (+09:00 -> 9*60*60)
      String      :repeat_at, default: ''
      String      :repeat_set_time
      String      :repeat_random_every # random's time day or week on Mon, Tue... eg. '* * 1,2'
      String      :repeat_random_start
      String      :repeat_random_end

      DateTime :created_at
      DateTime :updated_at

      unique %I[owner_study_id title]
    end
  end
end
