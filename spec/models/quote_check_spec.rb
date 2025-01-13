# frozen_string_literal: true

require "rails_helper"

RSpec.describe QuoteCheck do
  describe "validations" do
    let(:attributes) { create(:quote_check).attributes }

    describe "metadata" do
      it "allows nil" do
        expect(described_class.new(attributes.merge(metadata: nil))).to be_valid
      end

      it "allows {}" do
        expect(described_class.new(attributes.merge(metadata: {}))).to be_valid
      end

      it "allows {aides: [], gestes: []}" do
        expect(described_class.new(attributes.merge(metadata: { aides: [], gestes: [] }))).to be_valid
      end

      it "allows good values" do
        expect(described_class.new(attributes.merge(
                                     metadata: { aides: ["CEE"],
                                                 gestes: ["Remplacement des fenêtres ou porte-fenêtres"] }
                                   ))).to be_valid
      end

      it "does not allow bad values" do
        expect(described_class.new(attributes.merge(metadata: { aides: ["bad"], gestes: ["bad"] }))).not_to be_valid
      end
    end
  end
end
