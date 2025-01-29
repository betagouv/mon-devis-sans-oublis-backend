# frozen_string_literal: true

require "rails_helper"

RSpec.describe StatsService, type: :service do
  let(:matomo_api) { instance_double(MatomoApi) }

  before do
    allow(MatomoApi).to receive_messages(auto_configured?: true, new: matomo_api)
    allow(matomo_api).to receive(:value).and_return(42)
  end

  describe ".all" do
    subject(:all) { described_class.new.all }

    context "with no quote checks" do
      it "returns the stats" do # rubocop:disable RSpec/ExampleLength
        expect(all).to eq(
          quote_checks_count: 0,
          average_quote_check_errors_count: nil,
          average_quote_check_processing_time: nil,
          average_quote_check_cost: nil,
          median_quote_check_processing_time: nil,
          unique_visitors_count: 42
        )
      end
    end

    context "with quote checks" do
      before do
        create(:quote_check, :valid)
        create(:quote_check, :invalid)
      end

      it "returns the stats" do # rubocop:disable RSpec/ExampleLength
        expect(all).to eq(
          quote_checks_count: 2,
          average_quote_check_errors_count: 0.5,
          average_quote_check_processing_time: 301, # 5 minutes
          average_quote_check_cost: nil,
          median_quote_check_processing_time: 301, # 5 minutes
          unique_visitors_count: 42
        )
      end
    end
  end
end
