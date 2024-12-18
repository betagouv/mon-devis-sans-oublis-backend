# frozen_string_literal: true

module QuoteValidator
  # Validator for the Quote
  class Base
    attr_accessor :error_details, :quote, :quote_id, :warnings

    # @param [Hash] quote
    # quote is a hash with the following keys
    # - siret: [String] the SIRET number of the company
    def initialize(quote_attributes, quote_id = nil)
      @quote = TrackingHash.new(quote_attributes)
      @quote_id = quote_id
    end

    def self.error_categories
      I18n.t("quote_validator.error_categories")
    end

    def self.error_types
      I18n.t("quote_validator.error_types")
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/ParameterLists
    def add_error(code,
                  category: nil, type: nil,
                  title: nil,
                  problem: nil, solution: nil,
                  value: nil)
      if category && self.class.error_categories.keys.include?(category)
        e = NotImplementedError.new("Category '#{category}' is not listed")
        ErrorNotifier.notify(e)
      end
      if type && self.class.error_types.keys.include?(type)
        e = NotImplementedError.new("Type '#{type}' is not listed")
        ErrorNotifier.notify(e)
      end

      @error_details << {
        id: "#{quote_id}##{@error_details.length + 1}",
        code:,
        category:, type:,
        title: title || I18n.t("quote_validator.errors.#{code}"),
        problem:, solution:,
        value:
      }
    end
    # rubocop:enable Metrics/ParameterLists
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    def errors
      error_details.map { |detail| detail.fetch(:code) }
    end

    def fields
      quote.keys_accessed
    end

    def validate!
      @error_details = []

      yield

      valid?
    end

    # doit valider les critères techniques associés aux gestes présents dans le devis
    def validate
      raise NotImplementedError
    end

    def valid?
      !error_details.nil? && error_details.empty?
    end
  end
end
