# frozen_string_literal: true

# Validator for the Quote
class QuoteValidator
  attr_accessor :errors

  # @param [Hash] quote
  # quote is a hash with the following keys
  # - siret: [String] the SIRET number of the company
  def initialize(quote)
    @quote = quote
  end

  def validate!
    @errors = []

    @errors << "SIRET number is missing" if @quote[:siret].blank?

    valid?
  end

  def valid?
    !@errors.nil? && @errors.empty?
  end
end
