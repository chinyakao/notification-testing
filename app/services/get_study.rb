# frozen_string_literal: true

module NotificationTesting
  # Models a secret study
  class GetStudy

    def call(id:)
      Study.where(id: id).first
    rescue
      puts 'fail to read study'
    end
  end
end