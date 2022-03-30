# frozen_string_literal: false

require 'dry-types'
require 'dry-struct'

require_relative 'study'

module NotificationTesting
  module Entity
    # Domain entity for team members
    class Reminder < Dry::Struct
      include Dry.Types

      attribute :id,            Integer.optional
      attribute :study,         Study
      attribute :type,          Strict::String
      attribute :code,          Strict::String
      attribute :remind_date,   Strict::String
      attribute :remind_time,   Strict::String
      attribute :content,       Strict::String

      def to_attr_hash
        to_hash.reject { |key, _| %i[id study].include? key }
      end
    end
  end
end
