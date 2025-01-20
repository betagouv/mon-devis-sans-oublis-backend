# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataAdeme, type: :service do
  describe "#historique_rge" do
    it "returns the history of a company", :vcr do
      data = described_class.new.historique_rge(qs: "siret:12345678900000")

      expect(data.fetch("results")).to be_an(Array)
    end

    context "when the service is unavailable" do
      before do
        stub_request(:get, /data\.ademe\.fr/)
          .to_return(status: 503, body: "all shards failed - rejected exe")
      end

      it "raises a ServiceUnavailableError" do
        expect { described_class.new.historique_rge(qs: "siret:12345678900000") }
          .to raise_error(described_class::ServiceUnavailableError)
      end
    end
  end
end
