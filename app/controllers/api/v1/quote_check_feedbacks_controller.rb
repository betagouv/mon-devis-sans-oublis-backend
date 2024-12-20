# frozen_string_literal: true

module Api
  module V1
    # Controller for QuoteCheckFeedbacks API
    class QuoteCheckFeedbacksController < BaseController
      before_action :authorize_request
      before_action :quote_check

      def create
        @quote_check_feedback = quote_check.feedbacks.create!(quote_check_feedback_params)

        render json: @quote_check_feedback.attributes.slice(
          "id", "quote_check_id", "validation_error_details_id", "is_helpful", "comment"
        ), status: :created
      end

      protected

      def quote_check
        @quote_check ||= QuoteCheck.find(params[:quote_check_id])
      end

      def quote_check_feedback_params
        params.permit(:validation_error_details_id, :is_helpful, :comment)
      end
    end
  end
end
