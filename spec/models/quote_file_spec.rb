# frozen_string_literal: true

require "rails_helper"

RSpec.describe QuoteFile do
  describe ".find_or_create_file" do
    it "does not save the same file twice" do
      file = fixture_file_upload("quote_files/Devis_test.pdf", "application/pdf")
      quote_file = described_class.find_or_create_file(file, file.original_filename)

      expect(described_class.find_or_create_file(file, file.original_filename)).to eq(quote_file)
    end
  end
end
