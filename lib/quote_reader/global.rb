# frozen_string_literal: true

module QuoteReader
  class UnsupportedFileType < StandardError; end

  # Read Quote from PDF file to extract Quote attributes
  class Global
    attr_reader :content, :content_type,
                :text,
                :anonymised_text,
                :naive_attributes, :naive_version,
                :qa_attributes, :qa_result, :qa_version,
                :read_attributes

    VERSION = "0.0.1"

    def initialize(content, content_type)
      @content = content
      @content_type = content_type
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def read
      if content_type != "application/pdf"
        raise QuoteReader::UnsupportedFileType,
              "File type #{content_type} not supported"
      end

      @text = Pdf.new(content).extract_text

      naive_reader = NaiveText.new(text)
      @naive_attributes = naive_reader.read
      @naive_version = naive_reader.version

      @anonymised_text = Anonymiser.new(text).anonymised_text

      qa_reader = Qa.new(anonymised_text)
      @qa_attributes = qa_reader.read
      @qa_result = qa_reader.result
      @qa_version = qa_reader.version

      @read_attributes = deep_merge_if_absent(naive_attributes, qa_attributes)
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

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
