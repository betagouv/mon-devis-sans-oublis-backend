# frozen_string_literal: true

module Api
  module V1
    # Controller for Stats API
    class StatsController < BaseController
      def index
        render json: StatsService.new.all
      end
    end
  end
end
