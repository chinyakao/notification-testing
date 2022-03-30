# frozen_string_literal: false

module NotificationTesting
  # Provides access to contributor data
  module Schedule
    # Data Mapper: Github contributor -> Member entity
    class ReminderMapper
      def initialize(gateway_class = Schedule::Api)
        @gateway = gateway_class.new
      end

      def load_several
        @gateway.reminders_data.map do |data|
          ReminderMapper.build_entity(data)
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
          Entity::Reminder.new(
            id: nil,
            type: type,
            code: code,
            remind_date: remind_date,
            remind_time: remind_time,
            content: content
          )
        end

        private

        def type
          @data['type']
        end

        def code
          @data['code']
        end
        
        def remind_date
          @data['remind_date']
        end
        
        def remind_time
          @data['remind_time']
        end

        def content
          @data['content']
        end
      end
    end
  end
end
