# frozen_string_literal: true

# QuoteCheck represents a submission of a quote to be checked.
class QuoteCheck < ApplicationRecord # rubocop:disable Metrics/ClassLength
  belongs_to :file, class_name: "QuoteFile"
  belongs_to :parent, class_name: "QuoteFile", optional: true

  has_many :feedbacks, class_name: "QuoteCheckFeedback", dependent: :destroy
  has_many :children, class_name: "QuoteFile", foreign_key: :parent_id, inverse_of: :parent, dependent: :nullify

  STATUSES = %w[pending valid invalid].freeze

  after_initialize :set_application_version
  before_validation :format_metadata

  PROFILES = %w[artisan particulier mandataire conseiller].freeze
  validates :profile, presence: true, inclusion: { in: PROFILES }

  validates :started_at, presence: true

  validate :metadata_data
  validate :validation_errors_as_array, if: -> { validation_errors.present? || validation_error_details.present? }
  validate :expected_validation_errors_as_array, if: -> { expected_validation_errors.present? }

  delegate :filename, to: :file, allow_nil: true

  scope :with_expected_value, -> { where.not(expected_validation_errors: nil) }
  scope :with_valid_processing_time, lambda {
    where.not(finished_at: nil)
         .where("finished_at - started_at > ? AND finished_at - started_at < ?", 0, 1_000.seconds.to_i)
  }

  def self.ransackable_attributes(_auth_object = nil)
    %i[with_expected_value]
  end

  # Returns a float number in €
  def cost
    return unless qa_result&.key?("usage")

    usage = qa_result.fetch("usage")
    Llms::Mistral.usage_cost_price(
      completion_tokens: usage.fetch("completion_tokens"),
      prompt_tokens: usage.fetch("prompt_tokens")
    )
  end

  def frontend_webapp_url
    return unless id

    profile_path = case profile
                   when "artisan" then "artisan"
                   when "conseiller" then "conseiller"
                   when "mandataire" then "mandataire"
                   when "particulier" then "particulier"
                   else
                     raise NotImplementedError, "Unknown path for profile: #{profile}"
                   end

    URI.join("#{ENV.fetch('FRONTEND_APPLICATION_HOST')}/", "#{profile_path}/", "televersement/", id).to_s
  end

  def processing_time
    return unless finished_at

    finished_at - started_at
  end

  def qa_llm
    case qa_result&.dig("id")
    when /\Achatcmpl-/
      "Albert"
    else
      "Mistral" if qa_model&.start_with?("mistral-")
    end
  end

  def qa_model
    qa_result&.dig("model")
  end

  # valid? is already used by the framework
  def quote_valid?
    validation_version.present? && validation_errors.blank?
  end

  def status
    return "pending" if finished_at.blank?

    validation_errors.blank? ? "valid" : "invalid"
  end

  def set_application_version
    self.application_version = Rails.application.config.application_version
  end

  # Sum of prompt and completion tokens
  def tokens_count
    return unless qa_result&.key?("usage")

    qa_result.fetch("usage").fetch("total_tokens")
  end

  def validation_errors_as_array
    errors.add(:validation_errors, "must be an array") if validation_errors && !validation_errors.is_a?(Array)
    return unless validation_error_details && !validation_error_details.is_a?(Array)

    errors.add(:validation_error_details, "must be an array")
  end

  def expected_validation_errors_as_array
    return unless expected_validation_errors && !expected_validation_errors.is_a?(Array)

    errors.add(:expected_validation_errors,
               "must be an array")
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
