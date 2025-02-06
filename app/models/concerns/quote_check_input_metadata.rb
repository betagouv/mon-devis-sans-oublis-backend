# frozen_string_literal: true

# Add profile and metadata from user inputs
module QuoteCheckInputMetadata
  extend ActiveSupport::Concern

  PROFILES = %w[artisan particulier mandataire conseiller].freeze

  included do
    validates :profile, presence: true, inclusion: { in: PROFILES }

    before_validation :format_metadata
    validate :metadata_data
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  def format_metadata
    self.metadata = metadata&.presence
    return unless metadata

    self.metadata = JSON.parse(metadata) if metadata.is_a?(String)
    self.metadata = metadata.transform_values(&:presence).compact # Remove empty values

    if metadata&.key?("gestes")
      metadata["gestes"] = # Backport
        metadata["gestes"].map do
          it.gsub("Poêle à granulés", "Poêle/insert à bois/granulés")
        end
    end

    metadata
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def metadata_data # rubocop:disable Metrics/MethodLength
    return unless metadata

    metadata_values = I18n.t("quote_checks.metadata").with_indifferent_access
    metadata.each do |key, values|
      next unless values

      errors.add(:metadata, "clé #{key} non autorisée") unless metadata_values.key?(key)

      key_values = metadata_values.fetch(key)
      key_values = key_values.flat_map { it.fetch(:values) } if key_values.first.is_a?(Hash)
      values.each do |value|
        errors.add(:metadata, "valeur #{value} non autorisée pour #{key}") unless key_values.include?(value)
      end
    end
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize
end
