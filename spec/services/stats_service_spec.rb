# frozen_string_literal: true

require "rails_helper"

RSpec.describe StatsService, type: :service do
  describe ".all" do
    before do
      create(:quote_check, :valid)
    end

    it "returns the stats" do
      expect(described_class.new.all).to eq(
        quote_checks_count: 1,
        average_quote_check_errors_count: 0.0,
        average_quote_check_processing_time: 301, # 5 minutes
        average_quote_check_cost: nil,
        unique_visitors_count: nil
      )
    end
  end
end
