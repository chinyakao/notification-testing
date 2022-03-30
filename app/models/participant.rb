# frozen_string_literal: false

require 'dry-struct'
require 'dry-types'

require_relative 'study'

module NotificationTesting
  module Entity
    # Domain entity for any coding projects
    class Participant < Dry::Struct
      include Dry.Types

      attribute :id,            Integer.optional
      attribute :study,         Study
      attribute :column_value,  Strict::String
      attribute :parameter,     Strict::String
      attribute :contact_type,  Strict::String
      attribute :contact_info,  Strict::String

      def to_attr_hash
        to_hash.reject { |key, _| %i[id study].include? key }
      end
    end
  end
end
