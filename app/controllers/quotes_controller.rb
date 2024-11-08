# frozen_string_literal: true

# Controller for the Quotes resource
class QuotesController < ApplicationController
  def check
    @quote_attributes ||= {
      siret: nil
    }

    return unless @quote_attributes

    quote_validation = QuoteValidator.new(@quote_attributes)
    quote_validation.validate!

    @quote_valid = quote_validation.valid?
    @quote_errors = quote_validation.errors
  end
end
