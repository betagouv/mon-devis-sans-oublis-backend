# frozen_string_literal: true

require "rails_helper"

RSpec.describe QuoteFile do
  describe ".find_or_create_file" do
    # rubocop:disable RSpec/ExampleLength
    # rubocop:disable RSpec/MultipleExpectations
    it "saves the file" do
      file = fixture_file_upload("quote_files/Devis_test.pdf", "application/pdf")
      quote_file = described_class.find_or_create_file(file, file.original_filename)

      expect(quote_file).to be_persisted

      quote_file.reload
      expect(quote_file.file).to be_attached
      expect(quote_file.content).not_to be_blank
    end
    # rubocop:enable RSpec/MultipleExpectations
    # rubocop:enable RSpec/ExampleLength

    it "does not save the same file twice" do
      file = fixture_file_upload("quote_files/Devis_test.pdf", "application/pdf")
      quote_file = described_class.find_or_create_file(file, file.original_filename)

      expect(described_class.find_or_create_file(file, file.original_filename)).to eq(quote_file)
    end

    context "with a non-PDF file" do
      it "still save it for further purpose" do
        file = fixture_file_upload("quote_files/Devis_test.png", "image/png")

        expect do
          described_class.find_or_create_file(file, file.original_filename)
        end.not_to raise_error
      end
    end
  end
end
