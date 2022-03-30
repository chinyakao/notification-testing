# frozen_string_literal: false

require 'yaml'
require 'http'

module NotificationTesting
  module Schedule
    # Library for Github Web API
    class Api
      def reminders_data
        # Request.new(@gh_token).repo(username, project_name).parse
        YAML.load(File.read('/Users/rileykao/Desktop/notification-testing /app/infrastructure/gateways/seeds/reminder_seeds.yml'))
      end

      def participants_data
        YAML.load(File.read('/Users/rileykao/Desktop/notification-testing /app/infrastructure/gateways/seeds/participant_seeds.yml'))
      end

      def studys_data(study_title)
        # Request.new(@gh_token).get(contributors_url).parse
        data_list = YAML.load(File.read('/Users/rileykao/Desktop/notification-testing /app/infrastructure/gateways/seeds/study_seeds.yml'))
        data_list.map do |data|
          return study = data if data['title'] == study_title
        end
      end

      # # Sends out HTTP requests to Github
      # class Request
      #   REPOS_PATH = 'https://api.github.com/repos/'.freeze

      #   def initialize(token)
      #     @token = token
      #   end

      #   def repo(username, project_name)
      #     get(REPOS_PATH + [username, project_name].join('/'))
      #   end

      #   def get(url)
      #     http_response = HTTP.headers(
      #       'Accept' => 'application/vnd.github.v3+json',
      #       'Authorization' => "token #{@token}"
      #     ).get(url)

      #     Response.new(http_response).tap do |response|
      #       raise(response.error) unless response.successful?
      #     end
      #   end
      # end

      # # Decorates HTTP responses from Github with success/error
      # class Response < SimpleDelegator
      #   Unauthorized = Class.new(StandardError)
      #   NotFound = Class.new(StandardError)

      #   HTTP_ERROR = {
      #     401 => Unauthorized,
      #     404 => NotFound
      #   }.freeze

      #   def successful?
      #     !HTTP_ERROR.keys.include?(code)
      #   end

      #   def error
      #     HTTP_ERROR[code]
      #   end
      # end
    end
  end
end
