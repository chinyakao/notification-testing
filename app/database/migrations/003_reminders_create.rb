# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:reminders) do
      primary_key :id
      foreign_key :owner_study_id, :studies, type: :uuid

      String      :type, default: 'fixed'
      String      :title, default: 'study_reminder', null: false
      Time        :reminder_date, default: Time.now
      String      :content

      DateTime :created_at
      DateTime :updated_at

      unique %I[owner_study_id title]
    end
  end
end
