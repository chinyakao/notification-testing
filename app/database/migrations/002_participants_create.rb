# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:participants) do
      primary_key :id
      foreign_key :owner_study_id, :studies
      uuid :parameter, primary_key: false
      
      String      :column_value
      String      :participant_code, null: false
      String      :contact_type
      String      :contact_info
      String      :aws_arn

      DateTime :created_at
      DateTime :updated_at

      unique %I[owner_study_id participant_code parameter]
    end
  end
end
