# frozen_string_literal: true

require "rails_helper"

RSpec.describe QuoteValidator::Global, type: :service do
  subject(:quote_validator) { described_class.new(quote_attributes) }

  let(:quote_attributes) do
    {}
  end

  describe "#validate!" do
    it "returns validation" do
      expect(quote_validator.validate!).to be false
    end
  end

  describe "#errors" do
    before { quote_validator.validate! }

    it "returns errors" do
      expect(quote_validator.errors).to include("devis_manquant")
    end
  end

  describe "#error_details" do
    before { quote_validator.validate! }

    it "returns error_details" do
      expect(quote_validator.error_details.dig(0, :code)).to eq("devis_manquant")
    end
  end
end
