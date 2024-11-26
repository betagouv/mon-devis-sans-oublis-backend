# frozen_string_literal: true

module QuoteReader
  # Read Quote from PDF file to extract Quote attributes
  class Global
    attr_reader :filepath

    VERSION = "0.0.1"

    def initialize(filepath)
      @filepath = filepath
    end

    def read_attributes
      quote_text = Pdf.new(filepath).extract_text
      naive_attributes = NaiveText.new(quote_text).read_attributes

      anonymised_text = Anonymiser.new(quote_text).anonymised_text
      qa_attributes = Qa.new(anonymised_text).read_attributes

      naive_attributes.merge(qa_attributes)
    end
  end
end
