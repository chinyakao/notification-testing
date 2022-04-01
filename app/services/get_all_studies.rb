# frozen_string_literal: true

module NotificationTesting
  # Models a secret studys
  class GetAllStudies

    def call
      Study.all
    rescue
      puts 'fail to read studys'
    end
  end
end
