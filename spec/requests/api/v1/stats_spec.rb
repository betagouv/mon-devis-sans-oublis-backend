# frozen_string_literal: true

# spec/controllers/posts_controller_spec.rb
require "rails_helper"

RSpec.describe "/api/v1/stats" do
  describe "GET /api/v1/stats" do
    let(:json) { response.parsed_body }

    it "returns a successful response" do
      get api_v1_stats_url
      expect(response).to be_successful
    end

    it "returns a complete response" do
      get api_v1_stats_url
      expect(json).to include(*StatsService.keys)
    end
  end
end
