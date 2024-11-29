# frozen_string_literal: true

# This class is responsible for checking the quote and returning the result.
class QuoteCheckService
  attr_reader :quote_check

  def initialize(tempfile, filename, profile)
    create_quote_check!(tempfile, filename, profile)
  end

  def self.quote_fields
    quote_validation = QuoteValidator::Global.new({})
    quote_validation.validate!
    quote_validation.fields
  end

  def self.default_quote_attributes(fields = quote_fields)
    fields.to_h do |field|
      if field.is_a?(Hash)
        [field.keys.first, default_quote_attributes(field.values.first)]
      elsif field.is_a?(Array)
        field
      else
        [field, nil]
      end
    end
  end

  def check
    read_quote
    validate_quote

    quote_check.update!(finished_at: Time.current)

    quote_check
  end

  private

  def create_quote_check!(tempfile, filename, profile)
    quote_file = QuoteFile.find_or_create_file(tempfile, filename)
    @quote_check = QuoteCheck.create!(
      file: quote_file,
      profile: profile,
      started_at: Time.current
    )
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def read_quote
    quote_reader = QuoteReader::Global.new(
      quote_check.file.content,
      quote_check.file.content_type
    )
    quote_reader.read

    quote_check.assign_attributes(
      text: quote_reader.text,
      anonymised_text: quote_reader.anonymised_text,
      naive_attributes: quote_reader.naive_attributes,
      naive_version: quote_reader.naive_version,
      qa_attributes: quote_reader.qa_attributes,
      qa_version: quote_reader.qa_version,
      read_attributes: quote_reader.read_attributes
    )
  rescue QuoteReader::ReadError
    quote_check.assign_attributes(
      validation_errors: ["file_reading_error"]
    )
  rescue QuoteReader::UnsupportedFileType
    quote_check.assign_attributes(
      validation_errors: ["unsupported_file_format"]
    )
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def validate_quote
    return if quote_check.read_attributes.blank?

    quote_validator = QuoteValidator::Global.new(quote_check.read_attributes)
    quote_check.assign_attributes(
      validation_errors: quote_validator.errors,
      validation_version: quote_validator.version
    )
  end
end
