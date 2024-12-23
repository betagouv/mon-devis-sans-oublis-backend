# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataAdeme, type: :service do
  describe "#historique_rge" do
    it "returns the history of a company", :vcr do
      data = described_class.new.historique_rge(qs: "siret:12345678900000")

      expect(data.fetch("results")).to be_an(Array)
    end
  end
end
