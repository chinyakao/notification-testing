# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:reminders) do
      primary_key :id
      foreign_key :owner_study_id, :studies

      String      :type
      String      :reminder_code, null: false
      String      :reminder_date
      String      :reminder_time
      String      :content

      DateTime :created_at
      DateTime :updated_at

      unique %I[owner_study_id reminder_code]
    end
  end
end
