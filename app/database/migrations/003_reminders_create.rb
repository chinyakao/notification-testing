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
      String      :repeat_set_random, default: 'set'
      String      :repeat_set_time
      # every day/week at specific time eg. '33 10 * * 0-4' -> every Sunday through Thursday at 10:33
      # convert back to human readable: https://github.com/alpinweis/cronex
      String      :repeat_random_every # random's time day or week on Mon, Tue... eg. '? ? * * 1,2'
      String      :repeat_random_start # random's time interval start
      String      :repeat_random_end   # random's time interval end

      DateTime :created_at
      DateTime :updated_at

      unique %I[owner_study_id title]
    end
  end
end

# String      :repeat_every       # day or week
# String      :repeat_on          # Mon, Tue...
# String      :repeat_at          # set_time or random
# String      :repeat_time        # set_time's specific time

# make a static cron job (everyday 00:05) query random reminder and set the random time for that day
# eg. every Mon and Tue 10:00AM to 12:00AM

# require 'time'
# repeat_random_start = Time.parse("10:00")
# => 2022-04-24 10:00:00 +0800

# repeat_random_end = Time.parse("12:00")
# => 2022-04-24 12:00:00 +0800

# t_result = repeat_random_start + rand(repeat_random_end - repeat_random_start)
# => 2022-04-24 11:14:20 +0800

# repeat_random_every[0] = t_result.min.to_s
# repeat_random_every[3] = t_result.hour.to_s
# => "14 11 * * 1,2"
