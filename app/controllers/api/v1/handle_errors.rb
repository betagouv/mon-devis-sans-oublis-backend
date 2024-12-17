# frozen_string_literal: true

module Api
  module V1
    # Module to handle and format exceptions automatically
    module HandleErrors
      extend ActiveSupport::Concern

      included do
        rescue_from ActionController::HttpAuthentication::Basic::AuthorizationError, with: :handle_unauthorized
        rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
        rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
        rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
      end

      private

      def api_error(error, message, status)
        render json: {
          error: error,
          message: Array.wrap(message)
        }, status: status
      end

      def handle_parameter_missing(exception)
        api_error("Parameter missing", exception.message, :bad_request)
      end

      def handle_record_invalid(exception)
        api_error("Validation failed", exception.record.errors.full_messages, :unprocessable_entity)
      end

      def handle_record_not_found(exception)
        api_error("Record not found", exception.message, :not_found)
      end

      def unauthorized(exception)
        api_error("Unauthorized", exception.message, :unauthorized)
      end
    end
  end
end
