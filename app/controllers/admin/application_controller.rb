# frozen_string_literal: true

module Admin
  # Super charge ActiveAdmin with HTTP Basic Auth
  class ApplicationController < ActionController::Base
    include HttpBasicAuthenticatable
  end
end
