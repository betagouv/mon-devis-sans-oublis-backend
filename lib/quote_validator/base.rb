# frozen_string_literal: true

module QuoteValidator
  # Validator for the Quote
  class Base
    attr_accessor :errors, :quote, :warnings

    # @param [Hash] quote
    # quote is a hash with the following keys
    # - siret: [String] the SIRET number of the company
    def initialize(quote)
      @quote = TrackingHash.new(quote)
    end

    def fields
      quote.keys_accessed
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
