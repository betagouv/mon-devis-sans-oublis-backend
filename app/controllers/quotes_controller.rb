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

  def default_quote_attributes
    {
      quote_number: nil,
      rge_number: nil,
      siret_number: nil
    }
  end

  def file_to_attributes(uploaded_file)
    temp_file_path = uploaded_file.tempfile.path

    QuoteReader.new(temp_file_path).read_attributes
  end

  def quote_validation(quote_attributes)
    quote_validation = QuoteValidator.new(quote_attributes)
    quote_validation.validate!

    @quote_valid = quote_validation.valid?
    @quote_errors = quote_validation.errors
  end
end
