# frozen_string_literal: true

# Controller for the Quotes resource
class QuotesController < ApplicationController
  def check
    @quote_attributes = if params[:quote_file].present?
                          file_to_attributes(params[:quote_file])
                        else
                          default_quote_attributes
                        end
    return unless @quote_attributes

    quote_validation(@quote_attributes)
  rescue QuoteReader::ReadError => e
    @quote_errors = [e.message]
  end

  protected

  def quote_fields
    quote_validation = QuoteValidator::Global.new({})
    quote_validation.validate!
    quote_validation.fields
  end

  def default_quote_attributes(fields = quote_fields)
    fields.to_h do |field, value|
      if value.is_a?(Hash)
        [field, default_quote_attributes(value)]
      else
        [field, nil]
      end
    end
  end

  def file_to_attributes(uploaded_file)
    temp_file_path = uploaded_file.tempfile.path

    QuoteReader::Global.new(temp_file_path).read_attributes
  end

  def quote_validation(quote_attributes)
    quote_validation = QuoteValidator::Global.new(quote_attributes)
    quote_validation.validate!

    @quote_valid = quote_validation.valid?
    @quote_errors = quote_validation.errors
  end
end
