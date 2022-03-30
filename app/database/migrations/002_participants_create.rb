# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:participants) do
      primary_key :id
      foreign_key :study_id

      String      :column_value
      String      :parameter, unique: true, null: false
      String      :contact_type
      String      :contact_info

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
