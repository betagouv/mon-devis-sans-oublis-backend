# frozen_string_literal: true

# Main controller for the application
class ApplicationController < ActionController::Base
  include HttpBasicAuthenticatable
end
