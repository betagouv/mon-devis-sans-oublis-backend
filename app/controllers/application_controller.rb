# frozen_string_literal: true

# Main controller for the application
class ApplicationController < ActionController::Base
  before_action :authenticate, if: -> { ENV.key?("MDSO_SITE_PASSWORD") }

  protected

  def authenticate
    authenticate_or_request_with_http_basic("Administration") do |username, password|
      username == "mdso" && password == ENV.fetch("MDSO_SITE_PASSWORD")
    end
  end
end
