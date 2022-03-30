# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:reminders) do
      primary_key :id
      foreign_key :study_id

      String      :type
      String      :code, unique: true, null: false
      String      :remind_date
      String      :remind_time
      String      :content

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
