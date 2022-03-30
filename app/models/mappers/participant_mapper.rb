# frozen_string_literal: false

module NotificationTesting
  # Provides access to contributor data
  module Schedule
    # Data Mapper: Github contributor -> Member entity
    class ParticipantMapper
      def initialize(gateway_class = Schedule::Api)
        @gateway = gateway_class.new
      end

      def load_several
        @gateway.participants_data.map do |data|
          ParticipantMapper.build_entity(data)
        end
      end

      def self.build_entity(data)
        DataMapper.new(data).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data)
          @data = data
        end

        def build_entity
          Entity::Participant.new(
            id: nil,
            study: study,
            column_value: column_value,
            parameter: parameter,
            contact_type: contact_type,
            contact_info: contact_info
          )
        end

        private

        def study
          StudyMapper.build_entity(@data['study'])
        end
        
        def column_value
          @data['column_value']
        end
        
        def parameter
          @data['parameter']
        end

        def contact_type
          @data['contact_type']
        end

        def contact_info
          @data['contact_info']
        end
      end
    end
  end
end
  