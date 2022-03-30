# frozen_string_literal: false

module NotificationTesting
  # Provides access to contributor data
  module Schedule
    # Data Mapper: Github contributor -> Member entity
    class StudyMapper
      def initialize(gateway_class = Schedule::Api)
        @gateway = gateway_class.new
      end

      def load_several
        @gateway.studys_data.map do |data|
          StudyMapper.build_entity(data)
        end
      end

      def find(study_title)
        data = @gateway.studys_data(study_title)
        build_entity(data)
      end

      def build_entity(data)
        DataMapper.new(data).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data)
          @data = data
        end

        def build_entity
          Entity::Study.new(
            id: nil,
            title: title,
            aws_arn: aws_arn
          )
        end

        private

        def title
          @data['title']
        end
        
        def aws_arn
          @data['aws_arn']
        end
      end
    end
  end
end
  