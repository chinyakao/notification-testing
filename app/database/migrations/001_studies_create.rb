# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:studies) do
      primary_key :id

      String      :title, unique: true, null: false
      String      :status, default: 'design'
      String      :aws_arn, unique: true

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
