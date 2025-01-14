# frozen_string_literal: true

module QuoteValidator
  # Validator for the Quote
  class Base
    class NotImplementedError < ::NotImplementedError; end

    attr_accessor :error_details, :quote, :quote_id, :warnings

    def self.geste_index(quote_id, geste_index)
      [quote_id, "geste", geste_index + 1].compact.join("-")
    end

    # @param [Hash] quote
    # quote is a hash with the following keys
    # - siret: [String] the SIRET number of the company
    def initialize(quote_attributes, quote_id: nil, error_details: nil)
      @quote = TrackingHash.new(quote_attributes)

      @quote_id = quote_id
      @error_details = error_details
    end

    def self.error_categories
      I18n.t("quote_validator.error_categories")
    end

    def self.error_types
      I18n.t("quote_validator.error_types")
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/ParameterLists
    def add_error(code,
                  category: nil, type: nil,
                  title: nil,
                  problem: nil, solution: nil,
                  geste: nil,
                  provided_value: nil,
                  value: nil) # value is DEPRECATED
      provided_value ||= value

      if category && self.class.error_categories.keys.include?(category)
        e = NotImplementedError.new("Category '#{category}' is not listed")
        ErrorNotifier.notify(e)
      end
      if type && self.class.error_types.keys.include?(type)
        e = NotImplementedError.new("Type '#{type}' is not listed")
        ErrorNotifier.notify(e)
      end

      error_details << {
        id: [quote_id, error_details.count + 1].compact.join("-"),
        geste_id: geste && self.class.geste_index(quote_id, quote.fetch("gestes")&.index(geste)),
        code:,
        category:, type:,
        title: title || I18n.t("quote_validator.errors.#{code}"),
        problem:,
        solution: solution || I18n.t("quote_validator.errors.#{code}_infos", default: nil),
        provided_value:
      }.compact
    end
    # rubocop:enable Metrics/ParameterLists
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize

    def errors
      error_details.map { it.fetch(:code) }
    end

    def fields
      quote.keys_accessed
    end

    def validate!
      @error_details ||= []

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
