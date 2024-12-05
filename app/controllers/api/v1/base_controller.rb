# frozen_string_literal: true

module Api
  module V1
    # Base controller for API V1
    class BaseController < ActionController::API
      before_action :authorize_request

      private

      def authorize_request
        # TODO: Implement API key authorization
      end
    end
  end
end
