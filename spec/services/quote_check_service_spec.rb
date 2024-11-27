# frozen_string_literal: true

require "rails_helper"

RSpec.describe QuoteCheckService, type: :service do
  let(:tempfile) { fixture_file_upload("quote_files/Devis_test.pdf", "application/pdf") }
  let(:filename) { File.basename(tempfile.path) }
  let(:profile) { "artisan" }

  describe "#initialize" do
    it "creates a new quote check" do
      expect { described_class.new(tempfile, filename, profile) }.to change(QuoteCheck, :count).by(1)
    end

    context "when the profile is not valid" do
      let(:profile) { "invalid" }

      it "raises an error" do
        expect { described_class.new(tempfile, filename, profile) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe "#check" do
    # rubocop:disable RSpec/ExampleLength
    # rubocop:disable RSpec/MultipleExpectations
    it "returns the completed quote check" do
      quote_check = described_class.new(tempfile, filename, profile).check

      expect(quote_check).to be_a(QuoteCheck)
      expect(quote_check.text).to be_a(String)
      expect(quote_check.anonymised_text).to be_a(String)
      expect(quote_check.read_attributes).to be_a(Hash)
      expect(quote_check.quote_valid?).to be_in([true, false])
      expect(quote_check.validation_errors).to be_nil

      expect(quote_check.read_attributes.dig(
               "pro", "siret"
             )).to eq("12345678900000")
    end
    # rubocop:enable RSpec/MultipleExpectations
    # rubocop:enable RSpec/ExampleLength
  end
end
