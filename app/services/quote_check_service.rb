# frozen_string_literal: true

# This class is responsible for checking the quote and returning the result.
class QuoteCheckService
  attr_reader :quote_check

  def initialize(
    tempfile_or_quote_check, filename = nil, profile = nil,
    parent_id: nil
  )
    @quote_check = if tempfile_or_quote_check.is_a?(QuoteCheck)
                     tempfile_or_quote_check
                   else
                     QuoteCheckUploadService.new(tempfile_or_quote_check, filename, profile, parent_id:).upload
                   end
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
    validate_quote if quote_check.validation_errors.blank?

    quote_check.update!(finished_at: Time.current)

    quote_check
  end

  private

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def read_quote
    quote_reader = QuoteReader::Global.new(
      quote_check.file.content,
      quote_check.file.content_type
    )
    quote_reader.read

    unless quote_reader.text&.strip.presence
      add_error("file_reading_error",
                category: "file",
                type: "error")
      return
    end

    quote_check.assign_attributes(
      text: quote_reader.text,
      anonymised_text: quote_reader.anonymised_text,
      naive_attributes: quote_reader.naive_attributes,
      naive_version: quote_reader.naive_version,
      qa_attributes: quote_reader.qa_attributes,
      qa_result: quote_reader.qa_result,
      qa_version: quote_reader.qa_version,
      read_attributes: quote_reader.read_attributes
    )
  rescue QuoteReader::ReadError
    add_error("file_reading_error",
              category: "file",
              type: "error")
  rescue QuoteReader::UnsupportedFileType
    add_error("unsupported_file_format",
              category: "file",
              type: "error")
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def validate_quote
    quote_validator = QuoteValidator::Global.new(quote_check.read_attributes)
    quote_validator.validate!

    quote_check.assign_attributes(
      validation_errors: quote_validator.errors,
      validation_error_details: quote_validator.error_details,
      validation_version: quote_validator.version
    )
  end

  # rubocop:disable Metrics/AbcSize
  def add_error(code,
                category: nil, type: nil,
                title: nil)
    quote_check.validation_errors ||= []
    quote_check.validation_errors << code

    quote_check.validation_error_details ||= []
    quote_check.validation_error_details << {
      id: [quote_check.id, quote_check.validation_error_details.count + 1].compact.join("-"),
      code:,
      category:, type:,
      title: title || I18n.t("quote_validator.errors.#{code}")
    }
  end
  # rubocop:enable Metrics/AbcSize
end
