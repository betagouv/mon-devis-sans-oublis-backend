# frozen_string_literal: true

module Api
  module V1
    # Controller for Profiles API
    class ProfilesController < BaseController
      def index
        render json: QuoteCheck::PROFILES
      end
    end
  end
end
