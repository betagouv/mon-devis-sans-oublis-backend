# frozen_string_literal: true

module Api
  module V1
    # Base controller for API V1
    class BaseController < ActionController::API
      include ActionController::HttpAuthentication::Basic::ControllerMethods
      include Api::V1::HandleErrors

      protected

      def authorize_request
        authenticate_or_request_with_http_basic do |username, password|
          username == "mdso" && password == ENV.fetch("MDSO_SITE_PASSWORD")
        end
      end
    end
  end
end
