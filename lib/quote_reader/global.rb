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

      deep_merge_if_absent(naive_attributes, qa_attributes)
    end

    private

    def deep_merge_if_absent(hash1, hash2)
      hash1.merge(hash2) do |_key, old_val, new_val|
        if old_val.is_a?(Hash) && new_val.is_a?(Hash)
          deep_merge_if_absent(old_val, new_val)
        else
          old_val.nil? ? new_val : old_val
        end
      end
    end
  end
end
