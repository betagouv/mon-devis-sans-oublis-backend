# frozen_string_literal: true

require "rails_helper"

RSpec.describe QuoteReader::Pdf, type: :service do
  let(:file) { fixture_file_upload("quote_files/Devis_test.pdf") }
  let(:content) { file.read }

  describe "#extract_text" do
    it "returns the content" do
      expect(described_class.new(content).extract_text).to include("Nice")
    end
  end
end
