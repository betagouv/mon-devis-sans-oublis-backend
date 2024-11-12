# frozen_string_literal: true

# Validator for the Quote
module QuoteValidator
  class Base
    attr_accessor :errors, :warnings

    # @param [Hash] quote
    # quote is a hash with the following keys
    # - siret: [String] the SIRET number of the company
    def initialize(quote)
      @quote = quote
    end

    def validate!
      @errors = []
      @warnings = []

      validate

      valid?
    end

    # doit valider les critères techniques associés aux gestes présents dans le devis
    def validate
      raise NotImplementedError
    end

    def valid?
      !@errors.nil? && @errors.empty?
    end
  end
end
