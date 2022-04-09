# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:participants) do
      uuid :id, primary_key: true
      foreign_key :owner_study_id, :studies, type: :uuid

      String      :details
      String      :nickname, null: false
      String      :contact_type
      String      :contact_info
      String      :aws_arn
      Bool        :confirm_status, default: false

      DateTime :created_at
      DateTime :updated_at

      unique %I[owner_study_id nickname contact_info]
    end
  end
end
