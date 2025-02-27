# frozen_string_literal: true

module QuoteReader
  class NoFileContentError < StandardError; end
  class UnsupportedFileType < StandardError; end

  # Read Quote from PDF file to extract Quote attributes
  class Global
    attr_reader :content, :content_type,
                :text,
                :shrinked_text,
                :anonymised_text,
                :naive_attributes, :naive_version,
                :private_data_qa_attributes, :private_data_qa_result, :private_data_qa_version,
                :qa_attributes, :qa_result, :qa_version,
                :read_attributes

    VERSION = "0.0.1"

    def initialize(content, content_type)
      @content = content
      @content_type = content_type
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def read(llm: nil)
      @text = case content_type
              when %r{^image/}
                Image.new(content, content_type).extract_text
              when "application/pdf"
                Pdf.new(content).extract_text
              else
                raise QuoteReader::UnsupportedFileType,
                      "File type #{content_type} not supported"
              end

      naive_reader = NaiveText.new(text)
      @naive_attributes = naive_reader.read
      @naive_version = naive_reader.version

      @shrinked_text = Shrinker.new(text).shrinked_text(naive_attributes)

      private_data_qa_reader = PrivateDataQa.new(shrinked_text)
      begin
        @private_data_qa_attributes = private_data_qa_reader.read || {}
      ensure
        @private_data_qa_result = private_data_qa_reader.result
        @private_data_qa_version = private_data_qa_reader.version
      end

      private_attributes = deep_merge_if_absent(
        @naive_attributes,
        @private_data_qa_attributes
      )

      private_extended_attributes = deep_merge_if_absent(
        private_attributes,
        ExtendedData.new(private_attributes).extended_attributes
      )
      @anonymised_text = Anonymiser.new(shrinked_text).anonymised_text(private_extended_attributes)

      qa_reader = Qa.new(anonymised_text)
      begin
        @qa_attributes = qa_reader.read(llm:) || {}
      ensure
        @qa_result = qa_reader.result
        @qa_version = qa_reader.version
      end

      @read_attributes = TrackingHash.nilify_empty_values(
        deep_merge_if_absent(
          private_extended_attributes,
          qa_attributes
        ),
        compact: true
      )
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    private

    def deep_merge_if_absent(hash1, hash2)
      hash1.merge(hash2) do |_key, old_val, new_val|
        if old_val.is_a?(Hash) && new_val.is_a?(Hash)
          deep_merge_if_absent(old_val, new_val)
        elsif old_val.is_a?(Array) && new_val.is_a?(Array)
          (old_val + new_val).presence
        else
          (old_val.nil? ? new_val : old_val).presence
        end
      end
    end
  end
end
