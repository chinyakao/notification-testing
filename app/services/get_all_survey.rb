# frozen_string_literal: true

module NotificationTesting
  # Get all survey 
  class GetAllSurvey
    # Error for cannot find an assignment
    class NotFoundError < StandardError
      def message
        'We could not find that assignment'
      end
    end

    # Assignment for given requestor account
    def self.call(auth:, assignment:)
      raise NotFoundError unless assignment
      policy = AssignmentPolicy.new(auth[:account], assignment, auth[:scope])
      raise ForbiddenError unless policy.can_view?

      assignment.full_details.merge(policies: policy.summary)
    end
  end
end