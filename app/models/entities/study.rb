# frozen_string_literal: false

require 'dry-struct'
require 'dry-types'


module NotificationTesting
  module Entity
    # Domain entity for any coding projects
    class Study < Dry::Struct
      include Dry.Types

      attribute :id,            Integer.optional
      attribute :title,         Strict::String
      attribute :aws_arn,       Strict::String

      def to_attr_hash
        to_hash.reject { |key, _| [:id].include? key }
      end
    end
  end
end
