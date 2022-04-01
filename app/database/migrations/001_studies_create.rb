# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:studies) do
      primary_key :id

      String      :title, unique: true, null: false
      String      :aws_arn

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
