# frozen_string_literal: true

# QuoteCheck represents a submission of a quote to be checked.
class QuoteCheck < ApplicationRecord
  belongs_to :file, class_name: "QuoteFile"

  PROFILES = %w[artisan particulier mandataire conseiller].freeze
  validates :profile, presence: true, inclusion: { in: PROFILES }

  validates :started_at, presence: true

  def status
    return "pending" if finished_at.blank?

    validation_errors.blank? ? "valid" : "invalid"
  end

  # valid? is already used by the framework
  def quote_valid?
    validation_version.present? && validation_errors.blank?
  end
end
