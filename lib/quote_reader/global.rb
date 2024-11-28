# frozen_string_literal: true

require "marcel"

module QuoteReader
  class UnsupportedFileType < StandardError; end

  # Read Quote from PDF file to extract Quote attributes
  class Global
    attr_reader :filepath,
                :text,
                :anonymised_text,
                :naive_attributes, :naive_version,
                :qa_attributes, :qa_version,
                :read_attributes

    VERSION = "0.0.1"

    def initialize(filepath)
      @filepath = filepath
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def read
      if content_type != "application/pdf"
        raise QuoteReader::UnsupportedFileType,
              "File type #{content_type} not supported"
      end

      @text = Pdf.new(filepath).extract_text

      naive_reader = NaiveText.new(text)
      @naive_attributes = naive_reader.read
      @naive_version = naive_reader.version

      @anonymised_text = Anonymiser.new(text).anonymised_text

      qa_reader = Qa.new(anonymised_text)
      @qa_attributes = qa_reader.read
      @qa_version = qa_reader.version

      @read_attributes = deep_merge_if_absent(naive_attributes, qa_attributes)
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    private

    def content_type
      @content_type ||= MIME::Types.type_for(filepath).first&.content_type || # From file name
                        Marcel::MimeType.for(Pathname.new(filepath)) # From file content
    end

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
