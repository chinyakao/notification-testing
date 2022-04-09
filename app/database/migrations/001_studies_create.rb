# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:studies) do
      uuid :id, primary_key: true

      String      :title, null: false
      String      :status, default: 'design'
      String      :aws_arn

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
