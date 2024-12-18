# frozen_string_literal: true

# QuoteCheck represents a submission of a quote to be checked.
class QuoteCheck < ApplicationRecord
  belongs_to :file, class_name: "QuoteFile"

  STATUSES = %w[pending valid invalid].freeze

  PROFILES = %w[artisan particulier mandataire conseiller].freeze
  validates :profile, presence: true, inclusion: { in: PROFILES }

  validates :started_at, presence: true

  validate :validation_errors_as_array, if: -> { validation_errors.present? || validation_error_details.present? }

  def validation_errors_as_array
    errors.add(:validation_errors, "must be an array") if validation_errors && !validation_errors.is_a?(Array)
    return unless validation_error_details && !validation_error_details.is_a?(Array)

    errors.add(:validation_error_details, "must be an array")
  end

  def status
    return "pending" if finished_at.blank?

    validation_errors.blank? ? "valid" : "invalid"
  end

  # valid? is already used by the framework
  def quote_valid?
    validation_version.present? && validation_errors.blank?
  end
end
