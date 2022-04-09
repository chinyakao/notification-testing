# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:participants) do
      primary_key :id
      foreign_key :owner_study_id, :studies
      uuid :parameter, primary_key: false

      String      :details
      String      :nickname, null: false
      String      :contact_type
      String      :contact_info
      String      :aws_arn, unique: true
      Bool        :confirm_status, default: false

      DateTime :created_at
      DateTime :updated_at

      unique %I[owner_study_id nickname parameter contact_info]
    end
  end
end
